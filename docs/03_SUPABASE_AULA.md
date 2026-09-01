# Supabase para levantar a todo el curso

## Estrategia recomendada para la sesión
El docente crea UN proyecto Supabase de aula. Todos usan el mismo URL + publishable/anon key, pero cada estudiante inicia sesión con su propia cuenta. Las políticas RLS hacen que cada usuario vea únicamente sus filas.

## Antes de clase
1. Crear proyecto Supabase.
2. En Authentication, para la sesión de aula puede deshabilitarse temporalmente `Confirm email` para evitar demoras de verificación.
3. Crear los usuarios de revisión indicados en el README.
4. Ejecutar una sola vez `supabase/00_base_de_datos_completa.sql` en SQL Editor.
5. Copiar `config/local.example.json` a `config/local.json`.
6. Completar URL y publishable/anon key.
7. Probar con dos usuarios distintos y comprobar que no ven los registros del otro.

## Nunca
- No usar `service_role` dentro de Flutter.
- No publicar `config/local.json`.
- No desactivar RLS para “hacerlo funcionar”.
