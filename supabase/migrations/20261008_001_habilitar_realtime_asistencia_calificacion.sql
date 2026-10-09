begin;

do $$
begin
  if not exists (
    select 1
    from pg_catalog.pg_publication
    where pubname = 'supabase_realtime'
  ) then
    raise exception 'No existe la publicacion supabase_realtime.';
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'asistencia'
  ) then
    execute 'alter publication supabase_realtime add table public.asistencia';
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'calificacion'
  ) then
    execute 'alter publication supabase_realtime add table public.calificacion';
  end if;
end;
$$;

commit;
