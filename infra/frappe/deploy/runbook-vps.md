# Runbook de despliegue — VPS Hostinger

Despliegue del piloto Frappe CRM + ERPNext en un **VPS de Hostinger** con Docker.

> **Por qué no el hosting web de Hostinger.** El importador de Git de Hostinger
> (Web Hosting) construye sitios estáticos o aplicaciones Node a partir de un
> `package.json`. Frappe CRM es un stack Python con MariaDB, Redis y procesos
> worker de larga duración: no puede ejecutarse en ese producto, y añadir un
> `package.json` solo publicaría los documentos de `docs/`, no el CRM.
> El plan (`docs/plan-piloto-frappe-crm-erpnext.md`) ya contempla esta vía como
> «VPS propio con Docker/Bench».

## 0. Requisitos

| Elemento | Mínimo recomendado |
| --- | --- |
| Plan VPS | 4 GB RAM / 2 vCPU (ERPNext + CRM + MariaDB) |
| Sistema | Ubuntu 24.04 LTS |
| Acceso | SSH con clave, usuario no root con sudo |
| DNS | Registro `A` de `SITE_NAME` → IP del VPS |
| Puertos | 80 y 443 abiertos; 22 restringido |

La imagen `CRM_IMAGE` debe estar **publicada en un registro** accesible por el
VPS. La imagen del smoke test local (`jarinox/frappe-crm:v15-pilot-20260809`)
solo existe en el Docker local: hay que subirla (`docker push`) o reconstruirla
en el VPS desde `infra/frappe/apps.json`.

## 1. Preparar el VPS

```bash
ssh usuario@IP_DEL_VPS

sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"   # requiere reconectar la sesión

sudo ufw allow OpenSSH
sudo ufw allow 80,443/tcp
sudo ufw enable
```

## 2. Obtener el repositorio y configurar secretos

```bash
git clone https://github.com/chrjmz/CRM-Jarinox.git
cd CRM-Jarinox/infra/frappe/deploy

cp .env.example .env
openssl rand -base64 32   # valor para DB_ROOT_PASSWORD
openssl rand -base64 24   # valor para ADMIN_PASSWORD
nano .env                 # rellenar SITE_NAME, correo, imagen y contraseñas
```

`.env` está cubierto por `.gitignore` y no debe versionarse nunca.

## 3. Levantar el stack

```bash
docker compose --env-file .env \
  -f compose.prod.yaml -f compose.caddy.yaml up -d

docker compose --env-file .env -f compose.prod.yaml ps
```

Caddy solicita el certificado TLS automáticamente en el primer arranque; si
falla, casi siempre es que el DNS aún no propaga o el puerto 80 está cerrado.

## 4. Crear el sitio (solo la primera vez)

```bash
source .env
docker compose --env-file .env -f compose.prod.yaml exec backend \
  bench new-site "$SITE_NAME" \
    --admin-password "$ADMIN_PASSWORD" \
    --db-root-password "$DB_ROOT_PASSWORD" \
    --install-app erpnext \
    --install-app crm \
    --set-default
```

Verificación: `https://SITE_NAME` debe cargar el login de Frappe por HTTPS.

## 5. Copias de seguridad

Frappe programa backups vía `scheduler`, pero quedan dentro del volumen. Para
sacarlos del VPS:

```bash
docker compose --env-file .env -f compose.prod.yaml exec backend \
  bench --site "$SITE_NAME" backup --with-files

docker compose --env-file .env -f compose.prod.yaml cp \
  backend:/home/frappe/frappe-bench/sites/"$SITE_NAME"/private/backups ./backups
```

Conviene automatizarlo con cron y copiarlo a almacenamiento externo antes de
cargar datos reales de clientes.

## 6. Actualizaciones

Las etiquetas de imagen son inmutables (ver `infra/frappe/version-lock.md`):
se actualiza cambiando `CRM_IMAGE` en `.env`, no reconstruyendo sobre la misma
etiqueta.

```bash
nano .env   # nueva etiqueta en CRM_IMAGE
docker compose --env-file .env -f compose.prod.yaml pull
docker compose --env-file .env \
  -f compose.prod.yaml -f compose.caddy.yaml up -d
docker compose --env-file .env -f compose.prod.yaml exec backend \
  bench --site "$SITE_NAME" migrate
```

Hacer siempre un backup (paso 5) antes de `migrate`.

## 7. Diagnóstico

```bash
docker compose --env-file .env -f compose.prod.yaml logs -f backend
docker compose --env-file .env -f compose.prod.yaml logs -f caddy
docker compose --env-file .env -f compose.prod.yaml exec backend bench doctor
```

| Síntoma | Causa habitual |
| --- | --- |
| 502 en el navegador | `backend` aún arrancando, o `configurator` falló |
| Certificado TLS no emitido | DNS sin propagar o puerto 80 cerrado |
| «Site does not exist» | Falta el paso 4, o `SITE_NAME` ≠ nombre del sitio |
| Websocket/tiempo real caído | Revisar el servicio `websocket` y la ruta `/socket.io/*` |
