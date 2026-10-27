# Cambios actuales

Fecha de actualización: 27 de octubre de 2026.

## Resumen académico del DOCENTE

Se incorporó una vista de consulta para que el DOCENTE revise únicamente la información de sus asignaturas:

```text
Mis asignaturas
  → seleccionar asignatura
  → Resumen académico
```

La pantalla presenta nombre, código, periodo, estado, estudiantes inscritos, asistencia, calificaciones, promedios y los estados sin datos correspondientes. También conserva el acceso a las pantallas existentes para registrar asistencia y calificaciones.

## Ajustes visuales recientes

- El estado de la asignación se muestra con un icono compacto para no cubrir ni comprimir el nombre de la materia.
- Una asignación activa utiliza un icono de confirmación.
- Una asignación inactiva utiliza un icono de cancelación.
- En móvil, todas las tarjetas de estudiantes tienen el mismo ancho.
- El contenido permanece alineado a la izquierda.
- En web se conserva la tabla responsive.
- Se mantienen Material 3 y los temas claro y oscuro.

Estos ajustes solo modifican presentación. No alteran controladores, repositorios, datasources, consultas, cálculos ni reglas académicas.

## Consultas reutilizadas

- `AsignacionDocenteRepository.listarPropiasActivas()`;
- `EstudianteRepository.listarPorAsignacion()`;
- `ConsultaAsistenciaRepository.listar()`;
- `CalificacionRepository.listarPorAsignacion()`.

No se agregaron consultas SQL, tablas ni valores derivados persistentes.

## Pruebas y compilación

- Pruebas nuevas del resumen académico: 10.
- Total de la suite: 214 pruebas aprobadas.
- `flutter analyze --no-pub`: sin observaciones.
- APK release configurada: compilación exitosa.
- Archivo de entrega: `APK/SFM_Tarija_1.0.5_release.apk`.
- Ejecución completa de las 214 pruebas: `Docs/evidencias/pruebas/flutter_test_e3.txt`.
- Reporte final escrito: `Docs/evidencias/pruebas/flutter_test_final.txt`.

Comando de compilación utilizado:

```powershell
flutter build apk --release --no-pub --dart-define-from-file=config/local.json
```

## Confirmación de seguridad

```text
CAMBIOS EN AUTENTICACIÓN: Ninguno
CAMBIOS EN ROLES: Ninguno
CAMBIOS EN RLS: Ninguno
CAMBIOS EN BACKEND: Ninguno
NUEVAS TABLAS: Ninguna
NUEVOS PERMISOS: Ninguno
```

La autorización continúa dependiendo de Supabase Auth, PostgreSQL y RLS. La aplicación no concede acceso a partir de `localStorage`, textos visuales ni parámetros de interfaz.
