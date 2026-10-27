# Configuración de Supabase

## Variables requeridas

Flutter necesita dos valores públicos:

```text
SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY
```

La aplicación lee estos valores en compilación. Si alguno falta, muestra la pantalla **Configuración requerida** y no inicializa Supabase.

## Configuración local

En PowerShell:

```powershell
Copy-Item config/local.example.json config/local.json
```

Completa `config/local.json`:

```json
{
  "SUPABASE_URL": "https://tu-proyecto.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_tu_clave_publica"
}
```

`config/local.json` contiene configuración local y no debe versionarse. Solo debe incluir la URL y la clave publicable/anon; nunca `service_role`.

## Ejecución

Web:

```powershell
flutter run -d chrome --dart-define-from-file=config/local.json
```

Android:

```powershell
flutter run --dart-define-from-file=config/local.json
```

## Compilación

Web de producción:

```powershell
flutter build web --release --no-pub --dart-define-from-file=config/local.json
```

APK de producción:

```powershell
flutter build apk --release --no-pub --dart-define-from-file=config/local.json
```

El resultado Android se genera en `build/app/outputs/flutter-apk/app-release.apk`. La copia de entrega vigente es `APK/SFM_Tarija_1.0.5_release.apk`.

## Seguridad y RLS

- Supabase Auth autentica la cuenta y entrega la sesión JWT.
- `perfil_usuario` determina el rol real del usuario.
- PostgreSQL/RLS limita las filas visibles o modificables.
- El DOCENTE solo debe recibir sus asignaciones y datos académicos relacionados.
- El ADMINISTRADOR conserva sus permisos administrativos existentes.
- La clave publicable puede estar en el cliente porque RLS controla la autorización.
- `service_role` debe permanecer exclusivamente en entornos seguros del backend.

## Resumen académico y Supabase

La pantalla `Resumen académico` no introduce políticas ni endpoints nuevos. Reutiliza las consultas existentes de asignaciones propias, estudiantes inscritos, asistencia y calificaciones. Los promedios y porcentajes se calculan en el dispositivo y no se escriben en PostgreSQL.

## Lo que no se debe hacer

- Compilar la APK sin `--dart-define-from-file=config/local.json`.
- Publicar `config/local.json`.
- Copiar `service_role` al archivo de configuración Flutter.
- Desactivar RLS para resolver un error de consulta.
- Autorizar acceso únicamente por el rol almacenado en la interfaz.
- Aplicar migraciones o cambiar políticas sin revisar primero el impacto.
