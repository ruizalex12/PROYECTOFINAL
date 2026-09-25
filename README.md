# Sistema Web y Móvil de Gestión Académica

## Seminario de Formación Ministerial Tarija

Proyecto desarrollado como trabajo final del **Diplomado en Desarrollo Web y Aplicaciones Móviles** de la **Universidad Autónoma Juan Misael Saracho (UAJMS)**, gestión 2026.

La solución centraliza la información académica del Seminario de Formación Ministerial Tarija mediante una aplicación Flutter para web y Android, con Supabase como backend.

## Roles del sistema

El sistema admite únicamente dos roles con acceso autenticado:

- `ADMINISTRADOR`
- `DOCENTE`

El estudiante es una entidad académica administrada por el Administrador. No es un usuario del sistema, no dispone de cuenta y no inicia sesión.

### Administrador

Puede administrar la información académica, incluidos estudiantes, docentes, asignaturas, periodos académicos, inscripciones, asignaciones docentes, asistencia, calificaciones y reportes.

### Docente

Puede iniciar sesión y acceder únicamente a la información académica autorizada correspondiente a sus asignaciones.

## Arquitectura y tecnologías

La aplicación utiliza una arquitectura cliente-servidor. Flutter proporciona los clientes web y Android, mientras que Supabase aporta autenticación, Data API/PostgREST, PostgreSQL y políticas Row Level Security (RLS).

Tecnologías principales:

- Flutter y Dart.
- Material 3.
- Supabase Auth.
- PostgreSQL y Data API/PostgREST.
- Row Level Security (RLS).
- Git y GitHub.
- Vercel para el despliegue web.

## Funcionalidad implementada

### RF-05 Gestión de Asignaturas

La vertical de Gestión de Asignaturas está implementada y permite:

- crear asignaturas;
- listar asignaturas;
- editar asignaturas;
- desactivar asignaturas;
- reactivar asignaturas.

La baja es lógica: al desactivar una asignatura se establece `estado=false`. No se utiliza `DELETE`, por lo que el registro permanece almacenado y puede reactivarse.

## Endpoint de comprobación

El archivo `api/v1/salud.js` implementa el endpoint de comprobación del servicio:

```http
GET /api/v1/salud
```

## Estructura de `lib/`

```text
lib/
├── core/
├── features/
│   ├── auth/
│   └── asignaturas/
├── routes/
├── shared/
├── app.dart
└── main.dart
```

- `core/`: configuración, manejo de errores, servicios y tema compartido.
- `features/auth/`: autenticación y autorización de los roles admitidos.
- `features/asignaturas/`: vertical de Gestión de Asignaturas, organizada por datos, dominio y presentación.
- `routes/`: rutas, nombres de rutas y protección de navegación.
- `shared/`: layouts y widgets reutilizables.
- `app.dart`: configuración principal de la aplicación.
- `main.dart`: punto de entrada.

## Configuración

Las únicas variables de configuración son:

```text
SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY
```

Para el desarrollo local se utiliza `config/local.json`:

```json
{
  "SUPABASE_URL": "URL_PUBLICA_DEL_PROYECTO",
  "SUPABASE_PUBLISHABLE_KEY": "CLAVE_PUBLICABLE_DEL_PROYECTO"
}
```

`config/local.json` contiene la configuración local y no se sube al repositorio. El archivo versionado `config/local.example.json` contiene solamente placeholders y sirve como plantilla; no debe contener URL, clave, contraseña ni otra credencial privada real.

La aplicación cliente debe usar exclusivamente la clave publicable de Supabase junto con políticas RLS adecuadas. Nunca se debe incluir una clave privilegiada, como `service_role`, en Flutter ni publicarla en el repositorio.

## Instalación y ejecución

Requisitos:

- Git.
- Flutter SDK y Dart SDK.
- Navegador compatible para la versión web.
- Android SDK, emulador o dispositivo físico para Android.
- Proyecto de Supabase configurado.

Instalar dependencias:

```bash
flutter pub get
```

Analizar el proyecto:

```bash
flutter analyze
```

Ejecutar en Chrome con la configuración local:

```bash
flutter run -d chrome --dart-define-from-file=config/local.json
```

Ejecutar en Android:

```bash
flutter run --dart-define-from-file=config/local.json
```

## Pruebas

Actualmente existen **8 tests aprobados**.

Para ejecutar la suite:

```bash
flutter test
```

## Compilación

Generar la aplicación web:

```bash
flutter build web --release --dart-define-from-file=config/local.json
```

Generar el APK:

```bash
flutter build apk --release --dart-define-from-file=config/local.json
```

El APK se genera normalmente en `build/app/outputs/flutter-apk/app-release.apk`.

## Seguridad

- La autenticación se gestiona mediante Supabase Auth.
- El acceso autenticado está restringido a `ADMINISTRADOR` y `DOCENTE`.
- Las sesiones utilizan JWT.
- Las políticas RLS restringen el acceso a los datos.
- El cliente no contiene credenciales privadas ni claves privilegiadas.
- Los docentes solo acceden a la información autorizada para sus asignaciones.

## Alcance

El proyecto se limita a la gestión académica. No incluye aula virtual, entrega de tareas, videoclases, foros, mensajería interna, pagos, facturación, biblioteca ni gestión médica o psicológica.

## Autor

**Alexander Ruiz Guerrero**

Diplomado en Desarrollo Web y Aplicaciones Móviles  
Universidad Autónoma Juan Misael Saracho — UAJMS  
Gestión 2026
