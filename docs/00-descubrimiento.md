# Fase 0 — Descubrimiento y diseño

## Estado

**En curso.** Se completaron la evaluación técnica y el smoke test local. Falta validar el proceso comercial y recibir los accesos de prueba.

## Hallazgos técnicos iniciales

| Componente | Estado | Observación |
| --- | --- | --- |
| Docker Desktop | Validado | Engine 29.4.3 y Docker Compose 5.1.4. |
| Recursos locales | Aptos para smoke test | 16 CPU y aproximadamente 8 GB asignados a Docker; evitar cargas grandes. |
| Git | Validado | Repositorio inicializado en la rama `main`. |
| Stack Frappe local | Validado | ERPNext, CRM, Ecommerce Integrations y Frappe WhatsApp instalados. |
| Dominio público/HTTPS | Pendiente | Necesario para webhooks de Shopify y Meta. |
| Shopify | Pendiente | No hay credenciales ni tienda de prueba conectada. |
| WhatsApp Business Platform | Pendiente | No hay credenciales ni número de prueba conectado. |
| WordPress | Fuera de esta etapa | Se diseñará el plugin después de validar el piloto. |

## Base técnica propuesta

Para el primer smoke test se usará Frappe/ERPNext v15 porque todas las aplicaciones requeridas tienen una rama compatible identificable:

- Frappe Framework: `version-15`.
- ERPNext: `version-15`.
- Frappe CRM: `main` estable, compatible con Frappe/ERPNext v15.
- Ecommerce Integrations: `version-15`.
- Frappe WhatsApp: `version-15`.

Los commits observados al iniciar el piloto quedan registrados en `infra/frappe/version-lock.md`. La imagen final deberá etiquetarse y conservarse para que las pruebas sean reproducibles.

El resultado técnico detallado está en `docs/01-smoke-test-local.md`.

## Riesgo técnico que el piloto debe resolver primero

El repositorio de `ecommerce_integrations` tiene reportes recientes relacionados con autenticación de Shopify y compatibilidad. Por eso la primera prueba de integración será autenticar una app personalizada y sincronizar un único pedido de prueba. Si falla, no se ampliará el alcance de datos hasta determinar si basta una corrección de configuración o si hace falta adaptar el conector.

## Proceso comercial propuesto para validar con Jarinox

Embudo inicial:

1. Nuevo.
2. Contactado.
3. Calificado.
4. Cotización enviada.
5. Negociación.
6. Ganado o Perdido.

Campos mínimos del lead:

- nombre o razón social;
- teléfono con código de país;
- correo;
- ciudad;
- origen (`Shopify`, `WhatsApp`, `WordPress`, referido u otro);
- producto o línea de interés;
- responsable;
- etapa;
- consentimiento de contacto, cuando corresponda;
- campaña/UTM, cuando exista.

## Información que debe aportar Jarinox

### Operación comercial

- Cantidad de asesores que usarán el CRM en el piloto.
- Etapas reales que usan hoy para vender.
- Quién asigna los leads y con qué criterio.
- Tiempo objetivo de primera respuesta.
- Razones habituales de pérdida.
- Si una venta puede involucrar cotización personalizada o únicamente compra directa en Shopify.

### Shopify

- URL administrativa de la tienda.
- Confirmación de si existe una tienda de desarrollo o si se usarán pedidos de prueba en la tienda real.
- Aplicaciones que intervienen en pagos, inventario, despacho y devoluciones.
- Países, monedas, impuestos y bodegas activas.
- Muestra acordada de 10–30 clientes y pedidos para conciliación.

### WhatsApp

- Indicar si el número actual usa WhatsApp personal, Business App o Business Platform/API.
- Propietario del Meta Business Manager.
- Número que se usará en el piloto.
- Usuarios que atenderán las conversaciones.
- Horarios y SLA de atención.

## Criterio de salida de Fase 0

La fase termina cuando estén aprobados:

- el embudo y los campos mínimos;
- las fuentes de verdad por entidad;
- los usuarios piloto y sus roles;
- el alojamiento del piloto;
- la estrategia de Shopify para pruebas;
- el número o cuenta de WhatsApp para pruebas;
- la matriz de casos de prueba del plan general.
