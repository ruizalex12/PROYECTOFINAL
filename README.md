# EduGestión 360 — Portal Académico

EduGestión 360 es una aplicación académica multiplataforma desarrollada con Flutter para centralizar la gestión de materias, estudiantes, docentes, tareas, entregas, evaluaciones, calificaciones, asistencias, horarios, anuncios y documentos.

El proyecto fue realizado como trabajo final del Diplomado en Desarrollo Web y Aplicaciones Móviles de la Universidad Autónoma Juan Misael Saracho (UAJMS), gestión 2026. Incluye interfaces diferenciadas según el rol y puede ejecutarse con Supabase o con datos locales temporales para una revisión inicial.

## 1. Problema y objetivo

En una institución educativa, las notas, asistencias, tareas, horarios y comunicaciones suelen administrarse con herramientas separadas. Esto dificulta el seguimiento académico y aumenta el riesgo de duplicar, perder o registrar incorrectamente la información.

EduGestión 360 busca reunir esos procesos en una sola aplicación para que:

- el personal académico gestione la estructura general de la institución;
- los docentes administren únicamente sus materias asignadas;
- los estudiantes consulten sus materias, tareas, notas, asistencias y documentos;
- los datos permanezcan protegidos mediante autenticación, roles y políticas de acceso.

## 2. Funcionalidades implementadas

### Acceso y seguridad

- Inicio y cierre de sesión.
- Acceso diferenciado para estudiante y docente.
- Redirección automática al portal correspondiente al rol.
- Autenticación mediante Supabase Auth.
- Protección de datos mediante Row Level Security (RLS).
- Restricción de la información por estudiante y por asignación docente.
- Almacenamiento privado de documentos en Supabase Storage.

### Portal del estudiante

- Inicio con resumen y accesos rápidos.
- Consulta de materias matriculadas.
- Visualización de docente, periodo, horario y aula.
- Consulta de tareas publicadas y estado de entrega.
- Entrega de tareas con comentario opcional y archivo real.
- Archivos de tarea admitidos: TXT, PDF, Word, JPG y PNG.
- Límite máximo de 10 MB por archivo.
- Consulta de calificaciones y cálculo del promedio.
- Resumen y porcentaje de asistencia.
- Marcación de asistencia dentro de cada materia cuando el docente abre una sesión.
- Consulta del horario semanal y anuncios.
- Carga y eliminación de documentos personales.
- Consulta y actualización del perfil.

### Portal del docente

- Consulta de las materias asignadas al docente autenticado.
- Resumen de materias y estudiantes.
- Consulta de estudiantes matriculados por materia.
- Apertura de sesiones temporales de asistencia.
- Registro y corrección manual de asistencia.
- Creación, edición y eliminación de tareas.
- Consulta y calificación de entregas.
- Visualización del comentario y nombre del archivo adjunto.
- Registro de retroalimentación.
- Creación de evaluaciones con fecha y ponderación.
- Registro y actualización de notas.
- Publicación de anuncios por materia.

### Gestión académica

- Panel con indicadores generales.
- Gestión de estudiantes, docentes, cursos, materias y periodos.
- Asignación de docentes y materias a cursos.
- Matrícula de estudiantes.
- Administración de roles.
- Creación, edición y eliminación de registros.
- Reportes y consultas académicas.
- Preferencias locales y tema oscuro.

### Ejecución local

La aplicación incluye datos académicos temporales en memoria para facilitar su revisión sin configurar Supabase. En esta modalidad se pueden recorrer los portales y probar los principales flujos, pero los cambios se pierden al reiniciar la aplicación.

## 3. Tecnologías utilizadas

| Tecnología            |                 Uso                         |
|     --                |                 ---                         |
| Flutter               |  Interfaz y compilación multiplataforma.    |
| Dart                  | Lenguaje principal.                         |
| Material 3            | Componentes visuales, temas y navegación.   |
| Supabase Auth         | Autenticación de usuarios.                  |
| Supabase PostgreSQL   | Persistencia académica.                     |
| Supabase RLS          | Seguridad según usuario y rol.              |
| Supabase Storage      | Documentos y archivos de entregas.          |
| Provider              | Estado global e inyección de configuración. |
| SharedPreferences     | Preferencias locales.                       |
| File Picker           | Selección de archivos del dispositivo.      |
| Flutter Test          | Pruebas automatizadas.                      |

El proyecto requiere Dart `>=3.4.0 <4.0.0`.

## 4. Requisitos

### Requisitos generales

- Git.
- Flutter SDK compatible con Dart 3.4 o superior.
- Android Studio o Visual Studio Code con Flutter y Dart.
- Android SDK.
- Emulador Android o dispositivo con depuración USB.
- Internet para descargar dependencias y utilizar Supabase.

Verificar el entorno:

```bash
flutter doctor
```

### Requisitos para Supabase

- Cuenta y proyecto de Supabase.
- URL y publishable key del proyecto.
- Acceso a SQL Editor y Authentication.

> Nunca se debe colocar una clave `service_role` dentro de Flutter.

## 5. Instalación

Clonar el repositorio y entrar en la carpeta:

```bash
git clone <URL_DEL_REPOSITORIO>
cd PROYECTO_FINAL_360_BASE
```

Si se recibió un ZIP, descomprimirlo y abrir una terminal en la carpeta donde está `pubspec.yaml`.

Instalar dependencias:

```bash
flutter pub get
```

Comprobar el proyecto:

```bash
flutter analyze
flutter test
```

El análisis debe finalizar sin problemas y las pruebas deben indicar `All tests passed`.

## 6. Configuración y ejecución

### Opción A: revisión local sin configurar Supabase

```bash
flutter run --dart-define-from-file=config/demo.json
```

Seleccionar estudiante o docente en el acceso. Las credenciales de revisión se cargan automáticamente.

### Opción B: ejecución con Supabase

#### 6.1. Crear la configuración local

En PowerShell:

```powershell
Copy-Item config\local.example.json config\local.json
```

En Linux o macOS:

```bash
cp config/local.example.json config/local.json
```

Completar `config/local.json`:

```json
{
  "DEMO_MODE": "false",
  "SUPABASE_URL": "https://SU-PROYECTO.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "SU_CLAVE_PUBLICA"
}
```

#### 6.2. Preparar la base de datos

Ejecutar en SQL Editor, en este orden:

1. `supabase/01_schema_y_rls.sql`
2. `supabase/02_gestion_academica.sql`
3. `supabase/03_roles_y_acceso.sql`
4. `supabase/04_portal_estudiantil.sql`
5. `supabase/05_datos_portal_estudiante.sql`

#### 6.3. Crear usuarios de revisión

En **Authentication > Users**:

```text
Estudiante
Correo: estudiante@seminariotarija.edu
Contraseña: Estudiante2026*

Docente
Correo: docente@seminariotarija.edu
Contraseña: Docente2026*
```

#### 6.4. Vincular cuentas y completar funciones

Después de crear las cuentas, ejecutar:

6. `supabase/06_cuentas_docente_estudiante.sql`
7. `supabase/07_tareas_y_asistencia_vinculada.sql`
8. `supabase/08_archivos_entregas.sql`

El script 06 vincula Authentication con los perfiles. El 07 habilita tareas, entregas y sesiones de asistencia. El 08 configura los formatos de archivos y el acceso docente a los adjuntos.

#### 6.5. Ejecutar

```bash
flutter run --dart-define-from-file=config/local.json
```

## 7. Estructura general

```text
PROYECTO_FINAL_360_BASE/
├── android/                 Proyecto nativo de Android
├── APK/                     APK preparado para entrega
├── config/                  Archivos de configuración dart-define
├── docs/                    Documentación complementaria
├── lib/
│   ├── config/              Configuración general
│   ├── controllers/         Controladores y preferencias
│   ├── models/              Entidades académicas
│   ├── repositories/        Repositorios locales y Supabase
│   ├── screens/             Pantallas y portales
│   ├── services/            Lógica académica, autenticación y archivos
│   ├── widgets/             Componentes reutilizables
│   ├── app.dart             MaterialApp y tema
│   └── main.dart            Punto de entrada
├── supabase/                SQL, RLS y datos iniciales
├── test/                    Pruebas automatizadas
├── web/                     Configuración web
├── windows/                 Configuración Windows
├── pubspec.yaml             Versión y dependencias
└── README.md                Documentación principal
```

### Organización interna

- Las pantallas consumen servicios especializados.
- `StudentService` gestiona las operaciones del estudiante.
- `TeacherService` gestiona materias, tareas, asistencia y notas.
- `EnrollmentService` gestiona matrículas y asignaciones.
- `AcademicService` administra registros generales.
- `ProfileService` obtiene el perfil y rol.
- `DemoAcademicStore` proporciona información temporal local.
- Supabase aplica la persistencia y las restricciones mediante RLS.

## 8. Generación del APK

### APK conectado a Supabase

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define-from-file=config/local.json
```

### APK para revisión local

```bash
flutter clean
flutter pub get
flutter build apk --release --dart-define-from-file=config/demo.json
```

El APK se genera en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Copiarlo a la carpeta de entrega desde PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path APK
Copy-Item build\app\outputs\flutter-apk\app-release.apk APK\EduGestion360_1.0.1_release.apk -Force
```

Antes de entregar se recomienda instalarlo en un dispositivo Android real y comprobar acceso, materias, tareas, archivos y asistencia.

## 9. Versión entregada

- Nombre: **EduGestión 360**.
- Paquete Flutter: `proyecto_final_360`.
- Versión: **1.0.1**.
- Número de compilación: **2**.
- Valor en `pubspec.yaml`: `1.0.1+2`.
- Plataforma principal: Android.

## 10. Limitaciones conocidas

- Supabase requiere conexión a Internet.
- Los datos locales en memoria se pierden al reiniciar.
- Los usuarios Auth deben crearse antes de ejecutar el script 06.
- El docente solo ve materias vinculadas mediante `docente_id`.
- El estudiante solo ve matrículas con estado `Inscrito`.
- La asistencia requiere una sesión vigente abierta por el docente.
- Los archivos tienen un límite de 10 MB y formatos restringidos.
- No existen notificaciones push; se utilizan anuncios y mensajes internos.
- La recuperación automática de contraseña por correo no está implementada.
- La publicación en Play Store y la firma con keystore de producción no forman parte de esta versión.

## 11. Autor

- **Autor:** Alexander Ruiz Guerrero.
- **Correo:** ruizguerrero02@gmail.com.
- **Programa:** Diplomado en Desarrollo Web y Aplicaciones Móviles.
- **Institución:** Universidad Autónoma Juan Misael Saracho (UAJMS).
- **Gestión:** 2026.

## 12. Comandos útiles

```bash
flutter pub get
flutter analyze
flutter test
flutter run --dart-define-from-file=config/demo.json
flutter run --dart-define-from-file=config/local.json
flutter build apk --release --dart-define-from-file=config/local.json
```
