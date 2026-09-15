# Registro de decisiones del piloto

## D-001 — Smoke test local con Docker

- Estado: aceptada provisionalmente.
- Fecha: 2026-08-09.
- Decisión: usar Docker Desktop local para comprobar instalación y compatibilidad antes de contratar o aprovisionar el alojamiento público.
- Motivo: permite detectar incompatibilidades sin exponer datos ni servicios en Internet.
- Límite: Shopify y WhatsApp requieren una URL HTTPS pública; su validación completa ocurrirá en el entorno público.

## D-002 — Línea base Frappe/ERPNext v15

- Estado: aceptada para el primer smoke test.
- Fecha: 2026-08-09.
- Decisión: comenzar con Frappe y ERPNext `version-15`, CRM `main`, Ecommerce Integrations `version-15` y Frappe WhatsApp `version-15`.
- Motivo: es el conjunto con ramas de compatibilidad comunes verificadas al inicio del piloto.
- Revisión: si Shopify exige cambios incompatibles o el smoke test falla, comparar con v16 antes de personalizar.

## D-003 — Shopify conserva autoridad sobre ecommerce

- Estado: propuesta, pendiente de aprobación de Jarinox.
- Decisión: Shopify será fuente principal de catálogo y pedidos durante el piloto; CRM administrará la relación comercial y ERPNext recibirá la copia operativa para validación.
- Consecuencia: el piloto no actualizará pedidos productivos desde ERPNext hacia Shopify salvo que un caso aprobado lo requiera expresamente.

## D-004 — Sin secretos ni datos personales en Git

- Estado: aceptada.
- Fecha: 2026-08-09.
- Decisión: usar archivos locales ignorados y un gestor de secretos; los datos de conciliación deberán anonimizarse o almacenarse fuera del repositorio.

## D-005 — No usar MariaDB 11.8 en el entorno público v15

- Estado: aceptada.
- Fecha: 2026-08-09.
- Decisión: el entorno público basado en Frappe v15 debe usar una versión de MariaDB dentro del rango probado por Frappe, a confirmar antes del despliegue.
- Motivo: el override actual de `frappe_docker` descargó MariaDB 11.8 y Frappe v15 mostró una advertencia explícita indicando que versiones superiores a 10.8 no están probadas.
- Situación local: se conserva temporalmente para el smoke test sin datos reales; no se considera una configuración aprobada para producción.


## D-006 — El hosting web de Hostinger no sirve para el piloto; se usa VPS

- Estado: aceptada.
- Fecha: 2026-09-15.
- Decisión: alojar el piloto en un **VPS de Hostinger con Docker**, no en el producto de Web Hosting con importación desde Git.
- Motivo: el importador de Git de Hostinger despliega sitios estáticos o aplicaciones Node a partir de un `package.json`. Frappe CRM + ERPNext es un stack Python con MariaDB, Redis y procesos worker persistentes, incompatible con ese producto. Añadir un `package.json` solo publicaría los documentos de `docs/`, sin CRM.
- Consecuencia: `infra/frappe/deploy/` versiona el compose de producción, la configuración TLS y el runbook.
- Ampliación (2026-09-15): se confirmó con documentación oficial de Hostinger que el plan compartido Unlimited bloquea Frappe por cuatro motivos independientes: Python es exclusivo de VPS, Redis es exclusivo de VPS, los puertos son fijos (no se pueden abrir 8000/9000) y no se permite ejecutar programas compilados. No hay solución ni complemento de pago en el nivel compartido.

## D-007 — El piloto se despliega en el VPS compartido con otros sitios

- Estado: aceptada.
- Fecha: 2026-09-15.
- Decisión: desplegar el piloto en el VPS `srv438792` (KVM 8, Ubuntu 22.04, 31 GB RAM), que **ya aloja ~26 sitios en producción** de otros proyectos.
- Riesgo asumido: un error de configuración en Nginx afectaría a todos los sitios del servidor. Mitigación: Frappe se aísla en Docker escuchando solo en `127.0.0.1:8000`, se añade un `server block` nuevo sin modificar los existentes, y se conserva copia de `/etc/nginx` previa a cualquier cambio.
- Ajustes respecto a D-006: el puerto 8080 está ocupado por Nginx, por lo que Frappe usa el **8000**; no se utiliza Caddy (`compose.caddy.yaml` queda sin uso) porque Nginx ya gestiona 80/443 y los certificados.
- Nota: el servidor no tiene CloudPanel instalado, pese a que el panel de Hostinger lo mostraba; la configuración se hace directamente sobre Nginx.
