# CRM Jarinox

Repositorio de planificación, infraestructura y personalizaciones del piloto de **Frappe CRM + ERPNext** para Jarinox.

## Estado actual

- Fase activa: **Fase 0 — Descubrimiento y diseño**, con smoke test técnico local completado.
- Entorno local: Frappe CRM + ERPNext operativo en Docker, puerto `8081`.
- Integraciones productivas: no conectadas.
- Decisión de alojamiento público: **VPS con Docker** (ver D-006); VPS por contratar.

## Documentos principales

- [Plan general del piloto](docs/plan-piloto-frappe-crm-erpnext.md)
- [Descubrimiento inicial](docs/00-descubrimiento.md)
- [Checklist de accesos](docs/checklist-accesos.md)
- [Registro de decisiones](docs/registro-decisiones.md)
- [Resultado del smoke test local](docs/01-smoke-test-local.md)
- [Runbook del entorno local](infra/frappe/runbook-local.md)
- [Runbook de despliegue en VPS](infra/frappe/deploy/runbook-vps.md)

## Seguridad

No se deben guardar tokens, contraseñas, exportaciones de clientes ni archivos `.env` reales en Git. Los secretos deben entregarse mediante un gestor de contraseñas y cargarse únicamente en el entorno autorizado.
