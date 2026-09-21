# Sistema Web y Móvil de Gestión Académica

## Seminario de Formación Ministerial Tarija

Proyecto desarrollado como trabajo final del **Diplomado en Desarrollo Web y Aplicaciones Móviles** de la **Universidad Autónoma Juan Misael Saracho (UAJMS)**, gestión 2026.

La solución tiene como propósito centralizar la información académica del Seminario de Formación Ministerial Tarija mediante una aplicación web y móvil desarrollada con Flutter y servicios backend proporcionados por Supabase.

El sistema contempla tres perfiles de usuario:

- Administrador
- Docente
- Estudiante

Cada perfil dispone de funcionalidades y permisos diferenciados de acuerdo con sus responsabilidades dentro del proceso académico.

---

## 1. Problema

Actualmente, parte de la gestión académica del Seminario de Formación Ministerial Tarija se realiza mediante registros físicos, hojas de cálculo y un programa de funcionamiento local.

Esta forma de trabajo puede generar:

- duplicidad de información;
- errores durante la transcripción de datos;
- riesgo de inconsistencias;
- demoras en la actualización de información;
- dependencia del administrador para realizar consultas;
- acceso limitado a la información académica.

El proyecto busca centralizar estos procesos mediante una solución web y móvil.

---

## 2. Objetivo

Desarrollar un sistema web y móvil de gestión académica para el Seminario de Formación Ministerial Tarija que centralice la información académica y proporcione funcionalidades diferenciadas para administrador, docentes y estudiantes.

---

## 3. Alcance funcional

El sistema se centra exclusivamente en procesos de **gestión académica**.

### Administrador

El administrador podrá gestionar:

- cuentas y perfiles de usuario;
- estudiantes;
- docentes;
- asignaturas;
- periodos académicos;
- inscripciones;
- asignaciones docentes;
- asistencia;
- calificaciones;
- consultas y reportes académicos.

### Docente

El docente podrá:

- iniciar sesión;
- consultar sus asignaturas asignadas;
- consultar estudiantes relacionados con sus asignaturas;
- consultar información de asistencia;
- consultar calificaciones;
- acceder únicamente a la información académica autorizada.

### Estudiante

El estudiante podrá:

- iniciar sesión;
- consultar sus asignaturas;
- consultar su asistencia;
- consultar sus calificaciones;
- acceder únicamente a su propia información académica.

---

## 4. Funcionalidades principales

- Autenticación de usuarios.
- Gestión de perfiles y roles.
- Gestión de estudiantes.
- Gestión de docentes.
- Gestión de asignaturas.
- Gestión de periodos académicos.
- Inscripción de estudiantes.
- Asignación de docentes a asignaturas.
- Registro y consulta de asistencia.
- Registro y consulta de calificaciones.
- Consultas académicas según el perfil.
- Reportes académicos.
- Control de acceso según usuario y rol.

---

## 5. Funcionalidades fuera de alcance

La versión correspondiente al presente proyecto no contempla:

- aula virtual o LMS;
- entrega de tareas;
- gestión de archivos académicos;
- videoclases;
- foros;
- mensajería interna;
- gestión económica o financiera;
- pagos y facturación;
- biblioteca;
- gestión médica o psicológica;
- comunicación con familiares;
- auditoría avanzada de modificaciones.

Estas funcionalidades podrán ser consideradas en futuras versiones si la institución las requiere.

---

## 6. Arquitectura

El sistema utiliza una arquitectura **cliente-servidor apoyada en servicios Backend as a Service (BaaS)**.

Las aplicaciones desarrolladas con Flutter funcionan como clientes web y móvil, mientras que Supabase proporciona los servicios principales del backend.

Arquitectura general:

```text
Flutter Web
      │
      │ HTTPS / JSON
      ▼
   Supabase
      │
      ├── Supabase Auth
      ├── Data API / PostgREST
      ├── Edge Functions
      ├── Row Level Security
      │
      ▼
 PostgreSQL
      ▲
      │
      │ HTTPS / JSON
      │
Flutter Android
```

Las aplicaciones web y móvil utilizan una misma fuente centralizada de información.

---

## 7. Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Flutter SDK 3.47.0 Stable | Desarrollo de las aplicaciones web y Android |
| Dart SDK 3.13 | Lenguaje principal de desarrollo |
| Material 3 | Diseño de interfaces y componentes visuales |
| Supabase | Backend administrado |
| Supabase Auth | Autenticación y sesiones |
| supabase_flutter 2.17.2 | Integración entre Flutter y Supabase |
| Data API / PostgREST | Acceso a los datos mediante API REST |
| PostgreSQL | Persistencia de información académica |
| Row Level Security (RLS) | Restricción de acceso a datos |
| Supabase Edge Functions | Operaciones administrativas con privilegios elevados |
| Git 2.54.0.windows.1 | Control de versiones |
| GitHub | Repositorio remoto y respaldo del proyecto |

---

## 8. Modelo de datos

El modelo académico principal está compuesto por las siguientes entidades:

```text
perfil_usuario
asignatura
periodo_academico
inscripcion
asignacion_docente
asistencia
calificacion
```

La autenticación de las cuentas es administrada mediante:

```text
auth.users
```

de Supabase Auth.

### Relaciones principales

- Un estudiante puede tener varias inscripciones.
- Un docente puede tener varias asignaciones académicas.
- Una asignatura puede tener varios estudiantes inscritos.
- Una asignatura puede estar asignada a docentes.
- Un periodo académico puede contener múltiples inscripciones y asignaciones.
- Una inscripción puede tener registros de asistencia.
- Una inscripción puede tener registros de calificaciones.

---

## 9. Seguridad

La seguridad del sistema se basa en:

- autenticación mediante Supabase Auth;
- sesiones mediante JWT;
- perfiles diferenciados;
- políticas Row Level Security (RLS);
- restricción de información según el usuario autenticado;
- operaciones administrativas protegidas mediante Supabase Edge Functions;
- ausencia de claves privilegiadas dentro del código cliente.

### Reglas principales de acceso

**Administrador**

Puede gestionar la información académica autorizada.

**Docente**

Solo puede acceder a la información correspondiente a sus asignaciones académicas.

**Estudiante**

Solo puede consultar la información asociada a su propio perfil.

> Nunca se debe incluir una clave `service_role` de Supabase dentro de la aplicación Flutter ni publicarla en el repositorio.

---

## 10. Requisitos para ejecutar el proyecto

Se requiere:

- Git.
- Flutter SDK.
- Dart SDK.
- Android Studio o Visual Studio Code.
- Android SDK.
- Navegador web compatible.
- Emulador Android o dispositivo físico.
- Cuenta y proyecto de Supabase.
- Conexión a Internet.

Verificar Flutter:

```bash
flutter doctor
```

Verificar Git:

```bash
git --version
```

---

## 11. Instalación

Clonar el repositorio:

```bash
git clone https://github.com/ruizalex12/PROYECTOFINAL.git
```

Ingresar al proyecto:

```bash
cd PROYECTOFINAL
```

Instalar las dependencias:

```bash
flutter pub get
```

Analizar el proyecto:

```bash
flutter analyze
```

Ejecutar las pruebas:

```bash
flutter test
```

---

## 12. Configuración de Supabase

Para utilizar la aplicación con Supabase se requiere:

- URL del proyecto;
- clave pública o publishable key;
- Supabase Authentication habilitado;
- base de datos PostgreSQL configurada;
- políticas RLS correspondientes.

Las credenciales privadas no deben almacenarse directamente en el repositorio.

Ejemplo de configuración:

```json
{
  "DEMO_MODE": "false",
  "SUPABASE_URL": "https://TU-PROYECTO.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "TU_CLAVE_PUBLICA"
}
```

La clave mostrada en la documentación debe ser únicamente un ejemplo y nunca una credencial privada real.

---

## 13. Ejecución

### Aplicación conectada a Supabase

```bash
flutter run --dart-define-from-file=config/local.json
```

### Aplicación web

```bash
flutter run -d chrome --dart-define-from-file=config/local.json
```

### Aplicación Android

Con un dispositivo o emulador disponible:

```bash
flutter run --dart-define-from-file=config/local.json
```

---

## 14. Estructura general del proyecto

```text
PROYECTOFINAL/
├── android/
├── config/
├── docs/
├── lib/
│   ├── config/
│   ├── controllers/
│   ├── models/
│   ├── repositories/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   ├── app.dart
│   └── main.dart
├── supabase/
├── test/
├── web/
├── .gitignore
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
└── README.md
```

La estructura mantiene separadas las responsabilidades principales de la aplicación.

- `models`: representación de las entidades.
- `repositories`: acceso y persistencia de información.
- `services`: lógica de autenticación y gestión académica.
- `screens`: interfaces de usuario.
- `widgets`: componentes reutilizables.
- `supabase`: scripts SQL y configuración relacionada con la base de datos.
- `test`: pruebas automatizadas.
- `docs`: documentación complementaria.

---

## 15. Generación del APK

Antes de generar el APK:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

Generar la versión release:

```bash
flutter build apk --release --dart-define-from-file=config/local.json
```

El archivo generado estará disponible normalmente en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Antes de la entrega final se deberá probar el APK en un dispositivo Android.

---

## 16. Despliegue web en Vercel

El repositorio incluye `vercel.json` y `vercel-build.sh` para compilar y publicar Flutter Web automáticamente en Vercel.

### Configuración en Vercel

1. Importar en Vercel el repositorio `ruizalex12/PROYECTOFINAL`.
2. Mantener el directorio raíz del proyecto (`./`).
3. En **Settings > Environment Variables**, registrar las siguientes variables para Production, Preview y Development:

| Variable | Valor |
|---|---|
| `DEMO_MODE` | `false` |
| `SUPABASE_URL` | URL pública del proyecto Supabase |
| `SUPABASE_PUBLISHABLE_KEY` | Clave pública o publishable key de Supabase |

4. Presionar **Deploy**. Vercel ejecutará el script de compilación y publicará el contenido de `build/web`.

La configuración también redirige las rutas de la aplicación hacia `index.html`, lo que permite abrir y recargar rutas internas de Flutter Web sin obtener un error 404.

> Las variables definidas mediante `--dart-define` quedan incorporadas en la aplicación web compilada. Se debe utilizar únicamente la clave pública de Supabase, protegida con políticas RLS. Nunca se debe utilizar `service_role`.

### Compilación local

Para generar la versión web localmente:

```bash
flutter build web --release --dart-define-from-file=config/local.json
```

Los archivos de publicación se generan en:

```text
build/web/
```

---

## 17. Control de versiones

El proyecto utiliza **Git** para registrar los cambios realizados durante las diferentes iteraciones de desarrollo.

El repositorio remoto se encuentra alojado en GitHub:

```text
https://github.com/ruizalex12/PROYECTOFINAL
```

El historial existente del repositorio se mantiene como evidencia de la evolución del proyecto.

---

## 18. Limitaciones

- El funcionamiento conectado a Supabase requiere acceso a Internet.
- La disponibilidad depende también de los servicios externos utilizados.
- La versión actual se limita a procesos de gestión académica.
- No se incluye un entorno de aula virtual.
- No se incluyen pagos ni procesos financieros.
- No se incluyen tareas, entregas de archivos, mensajería o biblioteca.
- La publicación en Google Play Store no forma parte del alcance actual.
- El hosting web definitivo será seleccionado durante la etapa de despliegue.

---

## 19. Autor

**Alexander Ruiz Guerrero**

Diplomado en Desarrollo Web y Aplicaciones Móviles  
Universidad Autónoma Juan Misael Saracho — UAJMS  
Gestión 2026

---

## 20. Proyecto académico

**Título:**

> Desarrollo de un Sistema Web y Móvil de Gestión Académica para el Seminario de Formación Ministerial Tarija

**Ámbito beneficiario:**

Seminario de Formación Ministerial Tarija.

**Tipo de solución:**

Web + móvil.

**Gestión:**

2026.
