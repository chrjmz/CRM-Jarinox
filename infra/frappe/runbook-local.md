# Runbook del piloto local

## Estado actual

- URL: `http://localhost:8081`
- CRM: `http://localhost:8081/crm`
- Sitio Frappe: `localhost`
- Proyecto Docker: `jarinox-crm-pilot`
- Imagen: `jarinox/frappe-crm:v15-pilot-20260809`
- Archivos generados: `.runtime/frappe_docker` (ignorados por Git).

## Consultar estado

Desde `.runtime/frappe_docker`:

```powershell
docker compose -p jarinox-crm-pilot -f compose.pilot.yaml ps
docker compose -p jarinox-crm-pilot -f compose.pilot.yaml logs --tail 100 backend frontend scheduler
```

## Iniciar

```powershell
docker compose -p jarinox-crm-pilot -f compose.pilot.yaml up -d
```

## Detener sin borrar datos

```powershell
docker compose -p jarinox-crm-pilot -f compose.pilot.yaml stop
```

## Verificar aplicaciones

```powershell
docker compose -p jarinox-crm-pilot -f compose.pilot.yaml exec backend bench --site localhost list-apps
docker compose -p jarinox-crm-pilot -f compose.pilot.yaml exec backend bench --site localhost doctor
```

## Backup manual

```powershell
docker compose -p jarinox-crm-pilot -f compose.pilot.yaml exec backend bench --site localhost backup --with-files
```

## Consideraciones

- No ejecutar `down -v`: elimina los volúmenes del piloto.
- No exponer este stack a Internet: usa contraseñas locales temporales y MariaDB aún no está fijada a la versión aprobada.
- No copiar tokens de Shopify o Meta a `apps.json`, Markdown o archivos versionados.
- Antes del despliegue público, crear una configuración separada con HTTPS, secretos fuertes, backups y MariaDB compatible.

