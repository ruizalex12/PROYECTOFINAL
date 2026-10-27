# Errores comunes y soluciones

## La aplicación muestra “Configuración requerida”

La aplicación fue ejecutada o compilada sin `SUPABASE_URL` o `SUPABASE_PUBLISHABLE_KEY`.

Ejecuta:

```powershell
flutter run --dart-define-from-file=config/local.json
```

Para una APK:

```powershell
flutter build apk --release --no-pub --dart-define-from-file=config/local.json
```

Agregar el archivo después de compilar no corrige una APK existente; debe generarse nuevamente.

## Supabase no inicia

Comprueba que `config/local.json` exista, que los nombres de las variables sean exactos, que la URL comience con `https://`, que la clave sea la publicable/anon del mismo proyecto y que el comando incluya el archivo de configuración.

## El DOCENTE no ve una asignatura

Revisa primero que la asignación esté activa y relacionada con el usuario autenticado. Después comprueba la sesión y las políticas RLS. No alteres la interfaz para evadir esa validación.

## El resumen indica que la asignación no está disponible

El identificador de la ruta no pertenece a las asignaciones propias activas devueltas para el DOCENTE. Este rechazo es intencional y evita consultar asignaciones ajenas mediante parámetros manipulados.

## No aparecen estudiantes

Confirma que existan inscripciones activas para la asignación y periodo seleccionados. Si no existen, el estado vacío es el comportamiento esperado.

## Aparece “Sin asistencia”

Todavía no existen registros de asistencia para ese estudiante. No representa un error y no se crea ningún dato automático.

## Aparece “Sin calificación”

Todavía no existen calificaciones registradas para esa inscripción. La pantalla no asigna cero ni cambia la escala vigente de 0 a 100.

## Las tarjetas se ven con anchos diferentes en móvil

La vista actual fuerza todas las tarjetas al ancho disponible y las alinea a la izquierda. Si aparece el diseño anterior, desinstala la APK anterior e instala nuevamente `APK/SFM_Tarija_1.0.5_release.apk`.

## El título de la asignatura se comprime

La versión actual usa solamente un icono de confirmación para una asignación activa y un icono de cancelación para una inactiva. Ya no muestra un chip de texto junto al título.

## `new row violates row-level security policy`

La sesión no posee acceso a la fila o los datos enviados no cumplen la relación exigida por RLS. Revisa autenticación, rol, asignación e inscripción. No uses `service_role` en Flutter ni desactives RLS.

## `flutter pub get` falla

Ejecuta `flutter --version` y `flutter doctor`. Revisa la conexión y las versiones antes de modificar dependencias.

## La APK instalada no contiene el último cambio

Comprueba que instalaste `APK/SFM_Tarija_1.0.5_release.apk` y no una copia anterior. Después de una modificación visual o funcional, la APK debe compilarse y copiarse nuevamente.
