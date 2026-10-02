# Sistema Web y Móvil de Gestión Académica

## Seminario de Formación Ministerial Tarija

Aplicación académica desarrollada con Flutter y Supabase como trabajo final del Diplomado en Desarrollo Web y Aplicaciones Móviles de la Universidad Autónoma Juan Misael Saracho (UAJMS), gestión 2026.

El sistema centraliza la administración de usuarios, docentes, estudiantes y procesos académicos del Seminario de Formación Ministerial Tarija. Funciona en Flutter Web y Android, con PostgreSQL, Supabase Auth, PostgREST y Row Level Security (RLS) como backend.

## Roles

El sistema admite dos roles autenticados:

- `ADMINISTRADOR`
- `DOCENTE`

Los estudiantes son registros académicos. No poseen una cuenta de acceso ni inician sesión.

### Administrador

Puede gestionar usuarios, docentes, estudiantes, asignaturas, periodos académicos, inscripciones, asignaciones docentes, consultas de asistencia, calificaciones y reportes.

### Docente

Puede consultar sus asignaciones activas y trabajar únicamente con la información académica autorizada por RLS, incluyendo asistencia y calificaciones de los estudiantes relacionados con sus asignaturas.

## Funcionalidades implementadas

### Autenticación y autorización

- Inicio y cierre de sesión mediante Supabase Auth.
- Recuperación del perfil desde `public.perfil_usuario`.
- Redirección por rol y protección de rutas.
- Sesiones JWT y políticas RLS.

### Gestión de Usuarios

- Creación de cuentas `ADMINISTRADOR` y `DOCENTE`.
- Datos personales: nombres, apellidos, CI, teléfono, dirección, sexo y fecha de nacimiento.
- Formulario profesional dinámico para nuevas cuentas docentes.
- Edición de datos generales.
- Desactivación y reactivación de cuentas.
- Alta segura mediante la Edge Function `crear-usuario`.

Para nuevas cuentas `DOCENTE`, sexo, fecha de nacimiento y especialidad son obligatorios. Los valores admitidos por la interfaz para sexo son `MASCULINO` y `FEMENINO`.

### Gestión de Docentes

- Listado de perfiles con rol `DOCENTE`.
- Consulta del detalle personal y profesional.
- Edición de datos personales.
- UPSERT de información profesional en `public.datos_docente`.
- Desactivación y reactivación.
- Compatibilidad con docentes antiguos sin información profesional completa.

Las cuentas nuevas se crean exclusivamente desde Gestión de Usuarios.

### Gestión de Estudiantes

- Registro, listado y edición.
- Desactivación y reactivación.
- Búsqueda por nombre, CI y código.
- Código automático generado en PostgreSQL: `EST0001`, `EST0002`, etc.
- Código visible, único, obligatorio e inmutable.

Flutter no calcula ni envía el código durante el alta. La identity y el trigger de PostgreSQL son la única fuente de generación.

### Gestión académica

- Asignaturas: creación, edición, desactivación y reactivación.
- Periodos académicos: creación, edición y control de estado.
- Inscripciones de estudiantes por asignatura y periodo.
- Asignación de docentes activos a asignaturas y periodos.
- Consulta de asignaciones propias para docentes.
- Registro y actualización de asistencia.
- Registro y actualización de calificaciones entre 0 y 100.
- Consultas administrativas de asistencia y calificaciones.
- Reportes académicos y exportación CSV en web.

Las bajas son lógicas mediante `estado=false`; no se eliminan los registros académicos.

## Modelo de usuarios y docentes

```text
auth.users
    |
    | 1:1
    v
public.perfil_usuario
    |
    | 1 : 0..1
    v
public.datos_docente
```

- `perfil_usuario` contiene los datos generales de la cuenta y la persona.
- `datos_docente` contiene información profesional exclusiva del docente.
- La disponibilidad para asignaciones depende de `perfil_usuario.rol = 'DOCENTE'` y `perfil_usuario.estado = true`.

## Arquitectura

El código Flutter utiliza una organización feature-first con separación entre datos, dominio y presentación.

```text
lib/
|-- core/
|-- features/
|   |-- auth/
|   |-- usuarios/
|   |-- docentes/
|   |-- estudiantes/
|   |-- asignaturas/
|   |-- periodos/
|   |-- inscripciones/
|   |-- asignaciones_docente/
|   |-- asistencia/
|   |-- asistencias_admin/
|   |-- calificaciones/
|   |-- calificaciones_admin/
|   |-- reportes/
|   `-- dashboard/
|-- routes/
|-- shared/
|-- app.dart
`-- main.dart
```

Cada feature puede contener:

- `data/`: modelos, datasources e implementaciones de repositorio;
- `domain/`: entidades y contratos de repositorio;
- `presentation/`: controladores, páginas y widgets.

## Tecnologías

- Flutter y Dart.
- Material 3 y Provider.
- Supabase Flutter y Supabase Auth.
- PostgreSQL, PostgREST y Row Level Security.
- Supabase Edge Functions con Deno/TypeScript.
- Vercel para despliegue web.

## Configuración local

La aplicación requiere:

```text
SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY
```

Crear `config/local.json` a partir de `config/local.example.json`:

```json
{
  "SUPABASE_URL": "URL_PUBLICA_DEL_PROYECTO",
  "SUPABASE_PUBLISHABLE_KEY": "CLAVE_PUBLICABLE_DEL_PROYECTO"
}
```

`config/local.json` no debe versionarse. Flutter solo debe recibir la clave publicable; nunca se debe incluir `service_role` en el cliente.

## Instalación y ejecución

Requisitos:

- Flutter SDK compatible con Dart `>=3.4.0 <4.0.0`;
- Git y Chrome;
- Android SDK para ejecutar o compilar Android;
- un proyecto Supabase configurado.

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar en Chrome:

```bash
flutter run -d chrome --dart-define-from-file=config/local.json
```

Ejecutar en Android:

```bash
flutter run --dart-define-from-file=config/local.json
```

## Supabase

### Migraciones y auditorías

Las migraciones se encuentran en `supabase/migrations/` y deben aplicarse en orden cronológico.

El historial incluye migraciones que anteriormente fueron aplicadas manualmente. Antes de usar `supabase db push`, se debe comprobar que el historial local coincida con el remoto. No se debe reparar ni alterar el historial automáticamente sin revisar primero el proyecto Supabase.

Las auditorías SQL están en `supabase/tests/`. Varias se ejecutan dentro de una transacción y finalizan con `ROLLBACK`.

> Las secuencias PostgreSQL no son transaccionales. Una auditoría puede consumir valores y dejar saltos válidos en códigos `ESTxxxx`, aunque no deje filas de prueba persistentes.

### Edge Functions

- `crear-usuario`: crea Auth, perfil general y datos profesionales cuando el rol es `DOCENTE`.
- `crear-docente`: función histórica conservada; Gestión de Docentes no la utiliza para crear cuentas nuevas.

Despliegue manual de la función vigente:

```bash
npx supabase functions deploy crear-usuario
```

La clave `service_role` permanece exclusivamente en el entorno seguro de Supabase y nunca se expone a Flutter.

## Pruebas y calidad

```bash
flutter analyze --no-pub
flutter test --no-pub
flutter build web --release --no-pub --dart-define-from-file=config/local.json
git diff --check
```

La suite actual contiene **198 pruebas aprobadas**, incluyendo controladores, modelos, payloads y widgets responsive.

## Compilación

Web:

```bash
flutter build web --release --dart-define-from-file=config/local.json
```

Android APK:

```bash
flutter build apk --release --dart-define-from-file=config/local.json
```

El APK se genera normalmente en `build/app/outputs/flutter-apk/app-release.apk`.

## Despliegue web en Vercel

El repositorio incluye `vercel.json` y `vercel-build.sh`. En Vercel deben configurarse `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`.

Las reescrituras permiten recargar correctamente las rutas de Flutter Web.

## Endpoint de salud

```http
GET /api/v1/salud
```

Implementado en `api/v1/salud.js`.

## Seguridad

- Autenticación mediante Supabase Auth y JWT.
- RLS habilitado en las tablas expuestas.
- Helpers `SECURITY DEFINER` para comprobar roles sin recursión RLS.
- El administrador activo gestiona catálogos y perfiles.
- El docente solo accede a información relacionada con sus asignaciones.
- No se exponen claves privadas, contraseñas ni tokens en Flutter o logs.
- No se utiliza `DELETE` para bajas funcionales.

## Alcance

El proyecto está orientado a gestión académica. No incluye aula virtual, entrega de tareas, videoclases, foros, mensajería interna, pagos, facturación, biblioteca ni gestión médica o psicológica.

## Autor

**Alexander Ruiz Guerrero**

Diplomado en Desarrollo Web y Aplicaciones Móviles  
Universidad Autónoma Juan Misael Saracho — UAJMS  
Gestión 2026
