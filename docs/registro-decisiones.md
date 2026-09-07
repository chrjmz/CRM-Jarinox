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

