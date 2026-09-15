# Checklist de accesos para el piloto

Marcar cada elemento solo cuando el acceso haya sido probado. No pegar secretos en este documento.

## Jarinox

- [ ] Responsable ejecutivo del piloto confirmado.
- [ ] Líder comercial confirmado.
- [ ] Lista de usuarios piloto y correos corporativos.
- [ ] Aprobación para usar datos de prueba o una muestra controlada.
- [ ] Política de tratamiento de datos y consentimiento revisada.

## Infraestructura

- [x] Docker Desktop disponible para el smoke test local.
- [x] Imagen local construida con las cuatro aplicaciones.
- [x] Sitio local creado y endpoints básicos validados.
- [x] Alojamiento público elegido: **VPS con Docker** (descartado el hosting web de Hostinger; ver D-006).
- [ ] Subdominio del piloto definido.
- [ ] DNS administrable.
- [ ] HTTPS válido.
- [ ] Correo saliente de pruebas.
- [ ] Destino cifrado para backups.
- [ ] Gestor de secretos definido.

## Shopify

- [ ] URL de la tienda confirmada.
- [ ] Cuenta con permiso para crear e instalar una app personalizada.
- [ ] Entorno de prueba definido.
- [ ] App personalizada creada con mínimo privilegio.
- [ ] Token Admin API guardado fuera del repositorio.
- [ ] Permisos de clientes, productos, pedidos, inventario y fulfillment revisados.
- [ ] Webhooks configurados y firma validada.
- [ ] Pedidos/clientes de prueba identificados.

## Meta / WhatsApp

- [ ] Meta Business Manager identificado.
- [ ] Tipo de cuenta actual de WhatsApp confirmado.
- [ ] Número de piloto definido.
- [ ] WhatsApp Business Account disponible.
- [ ] Aplicación de Meta creada.
- [ ] Credenciales guardadas fuera del repositorio.
- [ ] Webhook HTTPS y token de verificación configurados.
- [ ] Plantilla de prueba aprobada.

## Regla para entrega de secretos

Los tokens y contraseñas deben compartirse mediante un gestor de contraseñas o canal seguro. Nunca por commits, capturas, documentos Markdown o mensajes que queden almacenados en el repositorio.
