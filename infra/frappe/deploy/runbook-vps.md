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

---

# Despliegue realizado — srv438792 (2026-09-15)

Estado: **stack operativo**, pendiente de publicar en CloudPanel.

## Entorno real

| Elemento | Valor |
| --- | --- |
| Servidor | `srv438792` — 8 vCPU, 31 GB RAM, Ubuntu 22.04 |
| IP | `93.127.200.73` |
| Repo desplegado | `/opt/crm-jarinox` |
| Imagen | `jarinox/frappe-crm:v15-pilot-20260915` (3.12 GB, local) |
| Escucha | `127.0.0.1:8000` (no expuesto a internet) |
| Apps | frappe 15.121.0, erpnext 15.121.3, crm 1.84.0 |

Este servidor aloja **21 sitios de producción ajenos al piloto** (D-007). Todo
cambio debe verificarse contra ellos antes y después.

## Particularidades frente al runbook genérico

- **No se usa Caddy.** Nginx de CloudPanel ya gestiona 80/443 y los certificados.
- **Puerto 8000**, no 8080: el 8080 está ocupado por Nginx.
- **`pull_policy: never`** en `compose.override.yaml`: la imagen se construye en
  el servidor y no existe en ningún registro remoto.
- La imagen se construye con `--secret id=apps_json`, **no** con
  `--build-arg APPS_JSON_BASE64`: el `Containerfile` de `images/layered/`
  espera un secret de BuildKit y descarta el build-arg en silencio, produciendo
  una imagen solo con Frappe.
- Se eliminó el paquete `podman-docker` (shim que ocupaba `/usr/bin/docker`)
  para poder instalar Docker CE. **Podman sigue instalado e intacto.**

## Reconstruir la imagen

```bash
/opt/build-crm.sh          # ~15 min, limitado a los núcleos 0-3
```

## Despliegue automático desde GitHub

`/etc/cron.d/crm-jarinox-deploy` ejecuta `/opt/crm-deploy.sh` cada 5 minutos:
hace `git pull` y, **solo si cambió algo bajo `infra/frappe/`**, recrea el
stack. Nunca toca otros sitios del servidor.

```bash
tail -f /var/log/crm-deploy.log    # seguimiento
```

Para cambios en `apps.json` hay que reconstruir la imagen a mano: el script no
la reconstruye.

## Paso pendiente: publicar el sitio en CloudPanel

CloudPanel genera los vhosts de `/etc/nginx/sites-enabled/`, por lo que el
sitio **debe crearse desde el panel** (D-008) y no a mano.

1. Entrar a `https://93.127.200.73:8443` (usuario `admin`).
2. **Add Site → Reverse Proxy**.
3. Dominio `crm.jarinox.com`, Reverse Proxy URL `http://127.0.0.1:8000`.
4. En el sitio creado: **SSL/TLS → Let's Encrypt** para emitir el certificado.

El DNS de `crm.jarinox.com` ya resuelve a `93.127.200.73`.

## Credenciales

Generadas en el servidor y guardadas **solo** en
`/opt/crm-jarinox/infra/frappe/deploy/.env` (permisos `600`, ignorado por Git).

```bash
grep ADMIN_PASSWORD /opt/crm-jarinox/infra/frappe/deploy/.env
```

Usuario del sitio: `Administrator`.

## Publicación web — hecha (2026-09-17)

`https://crm.jarinox.com` operativo: certificado Let's Encrypt válido hasta
2026-12-16, HTTP redirige a HTTPS (301), sirve el login de Frappe.

El vhost está versionado en `nginx-crm.jarinox.com.conf` y desplegado en
`/etc/nginx/sites-available/crm.jarinox.com.conf`.

**El certificado NO está en `/etc/letsencrypt`**, sino aislado en
`/opt/crm-jarinox/web/letsencrypt`, para no mezclarlo con los 36 certificados
de los demás sitios del servidor. Renovación automática ya programada por
certbot. Para renovar a mano:

```bash
certbot renew --config-dir /opt/crm-jarinox/web/letsencrypt \
  --work-dir /opt/crm-jarinox/web/le-work \
  --logs-dir /opt/crm-jarinox/web/le-logs
```

### Riesgo pendiente

Este vhost se creó **fuera de CloudPanel** (contra lo previsto en D-008),
porque el panel no expone una CLI para crear sitios. Si CloudPanel regenera
las configuraciones de Nginx puede eliminarlo y el sitio caería sin aviso.
Antes de cargar datos reales conviene recrear el sitio desde el panel como
*Reverse Proxy* a `http://127.0.0.1:8000` y retirar este archivo.

### Sin `www`

Solo existe `crm.jarinox.com`. `www.crm.jarinox.com` no tiene registro DNS y
no está cubierto por el certificado; no se considera necesario.
