# BENISAT Mission Control

Sistema de coordinación del equipo BENISAT del IES Andrés Benítez para el reto CanSat Spain 2026–2027.

**Lema:** BENISAT · Misión: descubrir  
**Identidad institucional:** De Jerez al espacio.

## Objetivo

Centralizar actuaciones, calendario, documentación, difusión, presupuesto, ventas y patrocinios en una aplicación web compartida por el equipo.

## Arquitectura

- **Frontend:** HTML, CSS y JavaScript estáticos, desplegables en GitHub Pages.
- **Datos y autenticación:** Supabase (Postgres + Auth + Row Level Security).
- **Documentos y evidencias:** Google Drive, enlazado desde los registros.
- **Repositorio:** este proyecto, independiente de las cuentas personales para facilitar una futura transferencia.

## Principios de seguridad

- No guardar contraseñas, claves `service_role`, tokens ni secretos en este repositorio.
- La clave pública `anon`/publishable puede usarse en el frontend únicamente con RLS habilitado y políticas correctamente configuradas.
- No almacenar datos personales de alumnado que no sean necesarios.
- Cada persona debe usar su propia cuenta; no compartir credenciales.
- Las evidencias y documentos deben tener permisos de acceso restringidos.

## Estructura prevista

- `index.html`: aplicación web.
- `assets/css/app.css`: estilos.
- `assets/js/app.js`: interfaz y lógica del cliente.
- `assets/js/config.example.js`: ejemplo de configuración sin credenciales reales.
- `supabase/migrations/`: esquema de base de datos y políticas versionadas.
- `docs/`: guía de instalación, permisos, copias de seguridad y migración.

## Estado

Fase inicial: documentación y estructura base. Supabase todavía no está conectado y GitHub Pages no se ha configurado.

## Desarrollo y despliegue

Consulta `docs/SETUP.md` para preparar Supabase y publicar la aplicación.
