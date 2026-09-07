# Resultado del smoke test local

Fecha: 2026-08-09.

## Resultado

**Aprobado con una observación de base de datos.** Las aplicaciones requeridas compilaron, se instalaron en el mismo sitio y respondieron correctamente por HTTP.

## Componentes instalados

| Aplicación | Versión reportada |
| --- | --- |
| Frappe Framework | 15.117.0 |
| ERPNext | 15.119.0 |
| Ecommerce Integrations | 1.20.3 |
| Frappe CRM | 1.81.1 |
| Frappe WhatsApp | 1.0.12 |

Imagen local: `jarinox/frappe-crm:v15-pilot-20260809`.

## Validaciones ejecutadas

| Prueba | Resultado |
| --- | --- |
| Construcción de imagen con las cuatro apps | Correcto |
| Arranque de backend, frontend, websocket, scheduler y workers | Correcto |
| Salud de MariaDB | Correcto para smoke test |
| Creación del sitio `localhost` | Correcto |
| Instalación de ERPNext | Correcto |
| Instalación de Ecommerce Integrations | Correcto |
| Instalación de Frappe CRM | Correcto |
| Instalación de Frappe WhatsApp | Correcto |
| `GET /` | HTTP 200 |
| `GET /api/method/ping` | HTTP 200 |
| Login local | HTTP 200 |
| `GET /crm` autenticado | HTTP 200 |
| Workers | 2 en línea |
| Scheduler | Habilitado |

## Incidencias encontradas

### I-001 — Scripts CRLF en Windows

El primer arranque falló porque Git convirtió a CRLF los scripts de entrada del repositorio oficial `frappe_docker`. Linux devolvía `entrypoint.sh: no such file or directory` aunque el archivo existía.

Se normalizaron los scripts a LF y se agregó `.gitattributes` al repositorio de Jarinox para prevenir el mismo problema en scripts propios. En futuras clonaciones de `frappe_docker` se debe usar `git -c core.autocrlf=false clone`.

### I-002 — MariaDB fuera del rango probado

El override oficial actual descargó MariaDB 11.8. Frappe v15 advirtió que las versiones superiores a 10.8 no están probadas. El smoke test puede continuar sin datos reales, pero el entorno público debe fijar una versión de MariaDB compatible y respaldada antes de recibir información de Jarinox.

### I-003 — Verificación visual pendiente

El navegador integrado de la sesión no pudo conectarse por una limitación del entorno. Se verificaron endpoints, autenticación, procesos y logs mediante HTTP y Docker. La revisión visual y el recorrido de interfaz quedan pendientes antes de capacitar usuarios.

## Credenciales locales temporales

El sitio solo escucha en el equipo local. Se creó con el usuario `Administrator` y una contraseña temporal de demostración. Estas credenciales no se reutilizarán en ningún entorno público ni se guardarán en Git.

## Próxima prueba técnica

Después de elegir el alojamiento público y crear una app de Shopify de pruebas:

1. Autenticar el conector sin importar datos históricos.
2. Sincronizar un único cliente y pedido de prueba.
3. Repetir el webhook y comprobar idempotencia.
4. Actualizar/reembolsar el pedido y conciliar el resultado.
5. Decidir si el conector funciona sin cambios o necesita adaptación.

