-- Habilita documentos de texto para entregas y permite al docente leer
-- los adjuntos de tareas pertenecientes a sus asignaciones.
update storage.buckets
set allowed_mime_types = array[
  'text/plain',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'image/jpeg',
  'image/png'
]
where id = 'documentos-estudiantes';

drop policy if exists storage_entregas_docente_select on storage.objects;
create policy storage_entregas_docente_select
on storage.objects for select to authenticated
using (
  bucket_id = 'documentos-estudiantes'
  and exists (
    select 1
    from public.entregas_tarea e
    join public.tareas t on t.id = e.tarea_id
    where e.archivo_ruta = name
      and docente_controla_asignacion(t.asignacion_id)
  )
);
