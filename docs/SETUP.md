# Preparación y despliegue · BENISAT Mission Control

## Enfoque actual

Aplicación personal para una única cuenta de usuario. No necesita gestión de miembros ni roles propios: Supabase Auth identifica al usuario y las políticas RLS limitan cada fila a esa cuenta.

## 1. Configurar la base de datos

1. Abre el proyecto de Supabase correspondiente a BENISAT.
2. En **SQL Editor**, crea una consulta nueva.
3. Abre `supabase/migrations/202610190001_initial_schema.sql`, copia el contenido completo y ejecútalo solo si el esquema de BENISAT aún no se ha creado en este proyecto.
4. La migración crea las tablas de tareas, hitos, patrocinadores, movimientos económicos, publicaciones y evidencias, con RLS activado.

**Importante:** esta migración simplificada está pensada para una base de datos vacía. Si ya ejecutaste una versión anterior de la migración o existen tablas con esos nombres, no la ejecutes sin revisar primero el estado para evitar errores o pérdida de datos.

## 2. Cuenta y configuración

- Crear una cuenta de usuario en **Authentication → Users**.
- La URL y la clave publicable de Supabase se configuran en `assets/js/config.js`.
- La clave publicable puede estar en el navegador; nunca guardar la clave `service_role`, contraseñas ni secretos en el repositorio.
- Para consultar o modificar los datos desde la aplicación, el usuario deberá iniciar sesión. Las políticas RLS solo permiten acceder a filas cuyo `owner_id` coincide con su usuario autenticado.

## 3. Publicar con GitHub Pages

1. En el repositorio, abre **Settings → Pages**.
2. Selecciona **Deploy from a branch**, rama `main`, carpeta `/ (root)`.
3. Guarda y espera a que GitHub publique la página.
4. La interfaz actual todavía requiere implementar y probar el inicio de sesión y las operaciones con la base de datos antes de usarla para gestionar datos reales.

## 4. Datos y seguridad

- No guardar información personal innecesaria del alumnado.
- No considerar privada una web solo porque no se anuncie su enlace.
- Mantener RLS activado en todas las tablas expuestas al frontend.
- Revisar permisos y probar lectura/escritura con la cuenta autenticada antes de introducir información real.
- Guardar documentos grandes en un servicio de archivos apropiado y registrar aquí sus enlaces cuando corresponda.

## 5. Portabilidad

- Mantener los cambios de estructura en archivos SQL dentro de `supabase/migrations/`.
- Para trasladar el proyecto, transferir/clonar el repositorio, crear o transferir el proyecto Supabase, aplicar las migraciones, restaurar los datos y archivos, actualizar la configuración y verificar el inicio de sesión.
- Una copia de la base de datos no incluye necesariamente los archivos de Storage ni los documentos externos de Drive.
