# Radiografía del sistema académico

## Recorrido general

El flujo principal de la aplicación es:

```text
main.dart
  → AppConfig
  → Supabase.initialize
  → Provider de repositorios
  → AppRouter
  → pantalla
  → controlador
  → repositorio
  → datasource
  → Supabase/PostgreSQL/RLS
```

La interfaz no decide los permisos. Las consultas se ejecutan con la sesión autenticada y PostgreSQL aplica las políticas RLS correspondientes.

## Archivos principales

- `lib/main.dart`: valida la configuración, inicializa Supabase y registra las dependencias.
- `lib/core/config/app_config.dart`: lee `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY` mediante `dart-define`.
- `lib/app.dart`: configura Material 3, temas y enrutamiento.
- `lib/routes/route_names.dart`: centraliza los nombres y rutas.
- `lib/routes/app_router.dart`: protege la navegación según la sesión y el rol.
- `lib/core/theme/`: controla los temas claro y oscuro.
- `lib/shared/`: contiene componentes reutilizables y tablas responsive.

## Organización por funcionalidad

El proyecto utiliza arquitectura feature-first:

```text
lib/features/<funcionalidad>/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
  presentation/
    controllers/
    pages/
    widgets/
```

Las funcionalidades principales son autenticación, usuarios, docentes, estudiantes, asignaturas, periodos, inscripciones, asignaciones docentes, asistencia, calificaciones, resumen académico, reportes y panel administrativo.

## Resumen académico del DOCENTE

El flujo disponible es:

```text
DOCENTE
  → Mis asignaturas
  → seleccionar una asignatura
  → Resumen académico
```

Archivos específicos:

- `lib/features/asignaciones_docente/presentation/pages/mis_asignaturas_page.dart`: abre el resumen de la asignación seleccionada.
- `lib/routes/route_names.dart`: declara `/docente/asignaturas/:id/resumen`.
- `lib/routes/app_router.dart`: construye y protege la pantalla del resumen.
- `lib/features/resumen_academico/domain/entities/resumen_academico.dart`: agrupa los datos y calcula porcentajes y promedios en memoria.
- `lib/features/resumen_academico/presentation/controllers/resumen_academico_controller.dart`: valida la asignación y coordina las consultas existentes.
- `lib/features/resumen_academico/presentation/pages/resumen_academico_page.dart`: presenta información, métricas, estudiantes y estados de interfaz.
- `test/resumen_academico_test.dart`: prueba cálculos, seguridad de la selección y comportamiento responsive.

### Consultas reutilizadas

El resumen no agrega consultas SQL ni tablas. Utiliza los repositorios existentes:

- `AsignacionDocenteRepository.listarPropiasActivas()`;
- `EstudianteRepository.listarPorAsignacion()`;
- `ConsultaAsistenciaRepository.listar()`;
- `CalificacionRepository.listarPorAsignacion()`.

Antes de cargar los datos, el controlador comprueba que el identificador solicitado pertenezca a las asignaciones propias activas devueltas bajo RLS.

### Cálculos no persistentes

- Asistencia individual: presentes sobre total de registros del estudiante.
- Asistencia general: presentes sobre total de registros de la asignatura.
- Promedio individual: suma de calificaciones del estudiante dividida entre la cantidad de registros.
- Promedio general: suma de calificaciones visibles dividida entre la cantidad de registros visibles.

Estos resultados se calculan en Flutter y no se guardan en PostgreSQL.

### Interfaz actual

- En móvil, los estudiantes se muestran en tarjetas del mismo ancho y alineadas a la izquierda.
- En web, se utiliza una tabla responsive.
- La asignación activa muestra un icono de confirmación compacto; una asignación inactiva muestra un icono de cancelación.
- Los botones de asistencia y calificaciones reutilizan las rutas y la lógica ya existentes.
- Se contemplan carga, error, lista vacía, falta de asistencia y falta de calificaciones.

## Supabase y base de datos

- `supabase/migrations/`: esquema y evolución de las nueve entidades académicas.
- `supabase/policies/`: políticas de acceso cuando corresponda.
- `supabase/tests/`: auditorías SQL y comprobaciones de seguridad.
- `supabase/functions/`: Edge Functions administrativas existentes.

La funcionalidad de resumen académico no modificó migraciones, RLS, autenticación, roles, Edge Functions ni el modelo de datos.

## Regla de mantenimiento

Para un cambio funcional, sigue el recorrido del dato antes de editar. Reutiliza repositorios y componentes existentes y valida siempre que la autorización real continúe en Supabase/PostgreSQL/RLS.
