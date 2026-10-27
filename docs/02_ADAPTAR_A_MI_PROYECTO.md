# Guía de mantenimiento del proyecto

Este repositorio ya corresponde al sistema académico del Seminario de Formación Ministerial Tarija. No es una plantilla `RegistroDemo` y no debe transformarse cambiando entidades o tablas de forma aislada.

## Alcance actual

El sistema administra nueve entidades existentes:

1. `perfil_usuario`;
2. `datos_docente`;
3. `estudiante`;
4. `asignatura`;
5. `periodo_academico`;
6. `inscripcion`;
7. `asignacion_docente`;
8. `asistencia`;
9. `calificacion`.

Los roles autenticados son `ADMINISTRADOR` y `DOCENTE`. Los estudiantes son registros académicos y no inician sesión.

## Procedimiento recomendado para cambios

1. Define el alcance y el rol afectado.
2. Revisa las entidades, repositorios, datasources y rutas existentes.
3. Confirma qué políticas RLS autorizan la consulta o escritura.
4. Reutiliza las consultas existentes siempre que sea posible.
5. Mantén los cálculos derivados en Flutter cuando no requieran persistencia.
6. Implementa la interfaz con Material 3 y soporte responsive.
7. Agrega pruebas únicamente para la funcionalidad nueva o modificada.
8. Ejecuta análisis, pruebas y compilaciones de verificación.
9. Actualiza `README.md` y la carpeta `Docs/`.
10. Genera el artefacto final con la configuración pública correcta.

## Restricciones de seguridad

- No confiar en `localStorage`, parámetros de ruta o textos visuales para conceder permisos.
- No incluir `service_role` en Flutter.
- No desactivar RLS para resolver errores de acceso.
- No modificar autenticación, roles o políticas RLS sin una revisión explícita.
- No guardar contraseñas, tokens ni claves privadas en el repositorio.
- No duplicar reglas de asistencia o calificación en una pantalla de consulta.

## Caso implementado: Resumen académico

La mejora del DOCENTE reutiliza sus permisos actuales y permite consultar información básica de una asignación propia, estudiantes inscritos, asistencia, calificaciones y estados vacíos.

La selección visual de una asignatura no concede acceso. El controlador vuelve a buscar las asignaciones propias activas mediante el repositorio y RLS antes de cargar estudiantes, asistencia o calificaciones.

## Lista de verificación antes de entregar

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter build web --release --no-pub --dart-define-from-file=config/local.json
flutter build apk --release --no-pub --dart-define-from-file=config/local.json
git diff --check
```

No omitas `--dart-define-from-file=config/local.json` al ejecutar o compilar una versión conectada a Supabase.
