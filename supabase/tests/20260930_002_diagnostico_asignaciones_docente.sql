-- Diagnostico de solo lectura para "Mis asignaturas".
-- Ejecutar en Supabase SQL Editor con permisos de administrador.

select
  pu.id as docente_id,
  pu.correo,
  concat_ws(' ', pu.nombres, pu.apellidos) as docente,
  pu.estado as perfil_activo,
  ad.id_asignacion,
  ad.estado as asignacion_activa,
  a.codigo as asignatura_codigo,
  a.nombre as asignatura,
  a.estado as asignatura_activa,
  p.nombre as periodo,
  p.estado as periodo_activo,
  case
    when ad.id_asignacion is null then 'SIN ASIGNACION'
    when not pu.estado then 'PERFIL INACTIVO'
    when not ad.estado then 'ASIGNACION INACTIVA'
    when not a.estado then 'ASIGNATURA INACTIVA'
    when not p.estado then 'PERIODO INACTIVO'
    else 'VISIBLE PARA EL DOCENTE'
  end as diagnostico
from public.perfil_usuario pu
left join public.asignacion_docente ad
  on ad.docente_id = pu.id
left join public.asignatura a
  on a.id_asignatura = ad.asignatura_id
left join public.periodo_academico p
  on p.id_periodo = ad.periodo_id
where pu.rol = 'DOCENTE'
order by pu.apellidos, pu.nombres, p.fecha_inicio desc, a.nombre;
