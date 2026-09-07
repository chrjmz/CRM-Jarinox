# Plan de piloto: Frappe CRM + ERPNext para Jarinox

## 1. Objetivo

Validar, en un entorno aislado de producción, que **Frappe CRM + ERPNext** puede centralizar los contactos, oportunidades y conversaciones de Jarinox, y sincronizar de forma fiable clientes y pedidos desde Shopify.

El piloto no sustituye los sistemas actuales ni modifica datos productivos de forma irreversible. Su resultado debe permitir decidir si se pasa a una implementación operativa y qué personalizaciones son realmente necesarias.

## 2. Alcance del piloto

### Incluido

- Instancia de pruebas de Frappe Framework con Frappe CRM, ERPNext y `ecommerce_integrations`.
- Configuración del equipo comercial, embudo de ventas, responsables, tareas y campos básicos.
- Sincronización controlada de Shopify: productos, clientes, pedidos, reembolsos y estados de despacho, según lo soporte el conector y las necesidades reales.
- Integración de un número de WhatsApp Business Platform de pruebas o un número habilitado para el piloto.
- Pruebas de recepción, asignación y seguimiento de leads.
- Pruebas de trazabilidad: contacto → conversación → oportunidad → pedido Shopify.
- Propuesta técnica para la posterior integración de formularios de WordPress.
- Capacitación breve de los usuarios participantes y recolección de retroalimentación.

### Excluido del piloto

- Migración histórica completa.
- Sustitución de la contabilidad, facturación electrónica o inventario de producción.
- Desarrollo del plugin de WordPress.
- Automatizaciones masivas de marketing por WhatsApp.
- Cambios permanentes al tema de Shopify.
- Puesta en producción final.

## 3. Resultado esperado y criterios de aceptación

El piloto se considera aprobado cuando se cumplen todos estos puntos:

1. Un pedido de prueba creado en Shopify llega una sola vez a ERPNext, con cliente, líneas de producto, total y estado identificables.
2. Un contacto de Shopify puede relacionarse con un Lead, Organización u Oportunidad en Frappe CRM sin duplicados críticos.
3. Un mensaje entrante de WhatsApp se asocia al contacto o lead correcto y puede ser atendido por un usuario asignado.
4. El equipo puede mover una oportunidad por el embudo, registrar notas/tareas y consultar su contexto comercial.
5. Se identifica el origen del lead (`Shopify`, `WhatsApp`, `WordPress`, referido u otro) y, cuando aplique, UTM/campaña.
6. Los errores de sincronización quedan registrados y se puede repetir una prueba sin generar datos duplicados.
7. Los usuarios participantes confirman que el flujo es utilizable y se documentan los ajustes pendientes.

## 4. Equipo y responsabilidades

| Rol | Responsabilidad |
| --- | --- |
| Patrocinador Jarinox | Priorizar objetivos, aprobar alcance y aceptar el piloto. |
| Líder comercial | Definir etapas del embudo, reglas de asignación y usuarios de prueba. |
| Administrador Shopify | Crear la app personalizada, otorgar permisos y habilitar webhooks. |
| Administrador Meta/WhatsApp | Gestionar Business Manager, número, plantillas y webhook. |
| Implementación técnica | Desplegar Frappe/ERPNext, configurar integraciones, pruebas y documentación. |
| Usuarios piloto | Ejecutar casos reales controlados y reportar fricciones. |

## 5. Decisiones que deben cerrarse antes de instalar

- Dónde se alojará el piloto: **Frappe Cloud** (menor operación) o VPS propio con Docker/Bench (mayor control).
- País, moneda, zona horaria, idioma y política de acceso de usuarios.
- Qué sistema será fuente de verdad por entidad durante el piloto:
  - catálogo y pedidos: Shopify;
  - actividad comercial y oportunidades: Frappe CRM;
  - conversaciones: WhatsApp/Frappe CRM;
  - contabilidad e inventario productivos: fuera de alcance inicialmente.
- Número de WhatsApp que participará y si se migrará uno existente.
- Número de usuarios piloto y etapas actuales de ventas.
- Política de datos personales, retención y permisos de acceso.

## 6. Requisitos previos

### Infraestructura

- Dominio o subdominio público para pruebas, por ejemplo `crm-piloto.jarinox.com`.
- HTTPS válido; es obligatorio para los webhooks de Shopify y Meta.
- Copias de seguridad automáticas de base de datos y archivos.
- Acceso administrativo al servidor o a Frappe Cloud.
- Correo saliente configurado para invitaciones y alertas.

### Shopify

- Acceso de propietario o de personal con permiso para desarrollar/instalar apps personalizadas.
- Tienda de desarrollo o colección/pedidos de prueba; no iniciar con sincronización histórica completa.
- App personalizada con token de Admin API, restringido a los permisos necesarios.
- Webhooks firmados para, como mínimo:
  - creación y actualización de pedidos;
  - creación y actualización de clientes;
  - reembolsos;
  - fulfillments/despachos, si Jarinox los usa.
- Inventario de campos y estados que debe conservar el CRM.

> El tema Shopify no requiere cambios para sincronizar ventas. Solo se tocará en una fase posterior para botones de WhatsApp, formularios o captura de atribución.

### WhatsApp

- Meta Business Manager con la empresa verificada, si Meta lo exige para el caso.
- Cuenta de WhatsApp Business Platform, aplicación de Meta y número disponible para API.
- Token y credenciales guardados en un gestor de secretos, nunca en el repositorio.
- URL pública de webhook y token de verificación.
- Al menos una plantilla aprobada para iniciar conversaciones empresariales.

### Datos y operación

- Lista de usuarios piloto, sus roles y correo corporativo.
- Export de referencia de clientes/pedidos recientes de Shopify para conciliación, sin importar todo aún.
- Definición de campos mínimos: nombre, teléfono normalizado con prefijo internacional, email, ciudad, origen, interés, responsable y etapa.

## 7. Plan de ejecución

### Fase 0 — Descubrimiento y diseño (2 a 3 días)

1. Realizar una sesión con ventas y operación para mapear el proceso actual desde primer contacto hasta venta/postventa.
2. Definir el embudo piloto. Propuesta inicial: `Nuevo` → `Contactado` → `Calificado` → `Cotización enviada` → `Negociación` → `Ganado` / `Perdido`.
3. Acordar campos obligatorios, fuentes de lead, causas de pérdida y reglas de asignación.
4. Inventariar apps actuales de Shopify, método de despacho, formas de pago y flujos de devolución.
5. Seleccionar 10–30 clientes y 10–30 pedidos recientes para pruebas de reconciliación.
6. Aprobar el diseño de datos y los casos de prueba antes de configurar conectores.

**Entregable:** mapa de proceso, diccionario de campos y matriz de pruebas aprobados.

### Fase 1 — Despliegue seguro (1 a 2 días)

1. Crear la instancia de piloto separada de producción.
2. Instalar versiones compatibles y estables de Frappe CRM, ERPNext y `ecommerce_integrations`.
3. Configurar dominio, HTTPS, correo, zona horaria `America/Bogota`, moneda y copias de seguridad.
4. Crear roles: Administrador, Comercial, Supervisor y Solo lectura.
5. Crear usuarios piloto y activar registro de auditoría.
6. Probar acceso, restauración de backup y envío de correo.

**Salida de fase:** instancia accesible solo para el equipo autorizado y con backup probado.

### Fase 2 — Configuración comercial de CRM (1 a 2 días)

1. Configurar el embudo, motivos de pérdida, territorios o equipos y responsables.
2. Añadir campos personalizados mínimos y vistas de trabajo para los asesores.
3. Configurar asignación manual inicialmente; automatizar solo cuando las reglas estén validadas.
4. Crear paneles básicos: leads nuevos, oportunidades por etapa, tareas vencidas, ventas ganadas y origen de leads.
5. Configurar plantillas de correo y actividades de seguimiento.

**Salida de fase:** un usuario comercial puede crear, calificar, asignar y cerrar una oportunidad.

### Fase 3 — Integración Shopify (2 a 4 días)

1. Crear una app personalizada exclusivamente para el piloto y limitar sus permisos.
2. Instalar/configurar el conector `ecommerce_integrations` en ERPNext.
3. Definir el mapeo de productos, variantes, clientes, impuestos, envíos, descuentos, pedidos y reembolsos.
4. Configurar webhooks con verificación de firma y una cola o registro de errores.
5. Ejecutar una sincronización inicial limitada y conciliarla con el export de referencia.
6. Crear pedidos de prueba para validar creación, actualización, cancelación/reembolso y despacho.
7. Documentar cualquier transformación necesaria; no modificar el tema Shopify para esta integración.

**Salida de fase:** los casos Shopify definidos en la sección 9 pasan sin duplicados ni pérdida de información relevante.

### Fase 4 — Integración WhatsApp (2 a 4 días, condicionada a Meta)

1. Instalar y configurar la aplicación Frappe WhatsApp compatible con Frappe CRM.
2. Configurar credenciales de Meta y webhook público; validar token y suscripciones a eventos.
3. Crear y aprobar una plantilla transaccional o comercial de prueba.
4. Probar mensaje entrante, respuesta de agente, mensaje con plantilla y asociación al lead/contacto.
5. Definir reglas operativas: tiempo de respuesta, responsable, horarios y manejo de conversaciones sin contacto existente.
6. Registrar limitaciones de Meta, especialmente las ventanas de atención y uso de plantillas.

**Salida de fase:** el historial de conversación está visible desde el registro comercial correcto.

### Fase 5 — Validación con usuarios (3 a 5 días)

1. Capacitar al equipo piloto mediante escenarios concretos, no solo una demostración.
2. Ejecutar los casos de prueba funcionales y registrar incidencias con severidad.
3. Operar casos reales controlados con el mínimo grupo de asesores definido.
4. Medir duplicados, fallos de sincronización, tiempos de respuesta y adopción.
5. Corregir configuración y repetir las pruebas afectadas.

**Salida de fase:** acta de resultados, lista priorizada de ajustes y recomendación de producción.

### Fase 6 — Cierre y decisión (1 día)

1. Comparar los resultados con los criterios de aceptación.
2. Estimar el esfuerzo de los cambios necesarios: integración WordPress, automatizaciones, migración histórica y reportes.
3. Decidir: pasar a producción, ampliar piloto o descartar/cambiar solución.
4. Si se aprueba, crear el plan de producción con ventana de corte, rollback y capacitación ampliada.

## 8. Diseño inicial de datos

| Entidad | Fuente principal | Identificador de deduplicación | Datos clave |
| --- | --- | --- | --- |
| Lead | WhatsApp, WordPress, Shopify | teléfono normalizado; email secundario | origen, campaña, interés, responsable, etapa |
| Contacto | Shopify / CRM | Shopify customer ID; email/teléfono | nombre, teléfono, email, consentimiento |
| Organización | CRM | dominio/email y revisión humana | razón social, segmento, ciudad |
| Oportunidad | CRM | ID interno | valor, etapa, productos de interés, fecha estimada |
| Pedido | Shopify | Shopify order ID | cliente, líneas, total, estado, descuentos, envío |
| Conversación | WhatsApp | message ID + teléfono | lead/contacto, agente, fechas, estado |

Regla inicial: Shopify conserva la autoridad sobre pedidos y clientes de ecommerce; CRM conserva la autoridad sobre clasificación comercial, responsables, tareas y oportunidades.

## 9. Casos de prueba mínimos

| ID | Escenario | Resultado esperado |
| --- | --- | --- |
| S-01 | Crear cliente y pedido Shopify | Cliente y pedido aparecen una vez con valores y líneas correctas. |
| S-02 | Actualizar dirección o pedido Shopify | Cambio se refleja según el mapeo definido y queda trazable. |
| S-03 | Reembolsar/cancelar pedido | Estado y referencia se actualizan sin borrar historial. |
| S-04 | Mensaje WhatsApp de número conocido | Conversación se vincula al contacto/lead existente. |
| S-05 | Mensaje WhatsApp de número nuevo | Se crea o propone un lead nuevo, con origen WhatsApp. |
| S-06 | Enviar plantilla WhatsApp | Se envía y registra con estado de entrega disponible. |
| C-01 | Convertir lead en oportunidad | Mantiene fuente, actividades y responsable. |
| C-02 | Cerrar oportunidad | Se exige motivo de pérdida o valor ganado y queda en reporte. |
| R-01 | Reenviar evento/webhook | No crea pedido, cliente ni conversación duplicados. |
| A-01 | Usuario comercial sin privilegios de admin | Solo ve y modifica los registros autorizados. |

## 10. Riesgos y controles

| Riesgo | Impacto | Control |
| --- | --- | --- |
| Aprobación o restricciones de Meta | Retrasa WhatsApp | Iniciar el alta de Meta al comienzo; usar número de prueba mientras tanto. |
| Duplicados por email/teléfono incompletos | Datos poco fiables | Normalizar teléfonos, usar IDs externos y reglas de deduplicación. |
| Mapeo incompleto de Shopify | Pedidos incongruentes | Sincronización limitada y conciliación antes de ampliar volumen. |
| Credenciales expuestas | Riesgo de seguridad | Gestor de secretos, mínimos privilegios y rotación de tokens. |
| Personalización prematura | Coste y retraso | Mantener el piloto estándar; documentar brechas antes de desarrollar. |
| Baja adopción del equipo | CRM sin valor | Usuarios piloto desde el diseño y capacitación con casos reales. |

## 11. Entregables del piloto

- Instancia de pruebas desplegada y documentada.
- Configuración exportable de CRM/ERPNext cuando sea posible.
- Matriz de permisos y usuarios.
- Mapeo Shopify ↔ ERPNext/CRM y listado de webhooks.
- Configuración y guía operativa de WhatsApp.
- Resultados de casos de prueba y registro de incidencias.
- Guía breve de uso para el equipo comercial.
- Backlog priorizado para WordPress, automatizaciones, migración y producción.
- Documento de decisión: aprobar, ampliar o descartar el paso a producción.

## 12. Propuesta para la fase posterior a piloto

Si el piloto se aprueba, el siguiente incremento será un plugin personalizado de WordPress que:

1. Capture formularios y datos de atribución (UTM, URL, campaña y referencia).
2. Envíe el lead al CRM mediante API autenticada.
3. Evite duplicados usando teléfono y email normalizados.
4. Registre errores y permita reintentos.
5. Respete consentimiento, privacidad y política de retención de Jarinox.

Antes de producción se deberá definir también la estrategia de migración histórica, monitoreo, soporte, backups, recuperación y capacitación de todo el equipo.
