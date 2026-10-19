# Preparación y despliegue

## Estado actual

El repositorio contiene la primera estructura de interfaz. Aún no se ha conectado a una instancia de Supabase, no hay autenticación y no se deben introducir datos reales en esta versión.

## 1. Crear Supabase

1. Crea un proyecto de Supabase bajo la cuenta u organización que deba administrarlo.
2. Guarda la contraseña de la base de datos en un gestor de contraseñas; no la añadas al repositorio.
3. Conserva la URL del proyecto y la clave publicable. La clave `service_role` es secreta y nunca debe estar en el navegador.
4. Aplica las migraciones SQL versionadas en `supabase/migrations/` en orden.
5. Antes de cargar datos, verifica que RLS está habilitado y que las políticas impiden acceso anónimo o entre equipos no autorizados.

## 2. Configurar el frontend

Edita `assets/js/config.js` con la URL y la clave publicable de la instancia. No introduzcas secretos. En una fase posterior sustituiremos este archivo por una configuración de despliegue más robusta si resulta necesario.

## 3. Publicar con GitHub Pages

1. En el repositorio, abre **Settings → Pages**.
2. Selecciona **Deploy from a branch**, rama `main`, carpeta `/ (root)`.
3. Guarda y espera a que GitHub publique la página.
4. Comprueba la web publicada en móvil y escritorio.

## 4. Usuarios y datos personales

- No usar cuentas compartidas; cada miembro debe tener su propia identidad.
- Recoger solo los datos necesarios para coordinar el proyecto.
- Evitar publicar nombres completos, correos, teléfonos, horarios individuales o información sensible del alumnado.
- Revisar los permisos de Drive: un enlace no equivale a un permiso seguro.
- Definir quién puede leer, crear, editar y borrar cada tipo de registro.

## 5. Portabilidad

- Mantener los cambios de estructura en archivos SQL dentro de `supabase/migrations/`.
- Documentar variables de configuración y servicios externos.
- Exportar periódicamente los datos y documentar cómo restaurarlos.
- Para trasladar el proyecto: transferir o clonar el repositorio, crear/transferir el proyecto Supabase, aplicar migraciones, restaurar datos y archivos, actualizar la configuración y verificar autenticación, políticas y enlaces.
- Una copia de la base de datos no incluye necesariamente los archivos almacenados en Storage ni los archivos externos de Drive.

## 6. Antes de usarlo con el equipo

La aplicación no debe considerarse lista para uso real hasta implementar autenticación, políticas RLS, gestión de errores, copias de seguridad y pruebas de acceso con cuentas distintas.