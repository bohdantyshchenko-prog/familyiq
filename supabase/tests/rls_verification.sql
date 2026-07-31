-- Run against an isolated Supabase test project after migrations.
-- The script fails fast when critical tenant-isolation policies are absent.

begin;

create temporary table expected_rls_tables(name text primary key);
insert into expected_rls_tables(name) values
  ('profiles'), ('families'), ('family_members'), ('family_entries'),
  ('media_assets'), ('family_invitations'), ('audit_events');

do $$
declare missing text;
begin
  select string_agg(e.name, ', ')
    into missing
    from expected_rls_tables e
    left join pg_class c on c.relname = e.name
    left join pg_namespace n on n.oid = c.relnamespace and n.nspname = 'public'
   where c.oid is null or not c.relrowsecurity;
  if missing is not null then
    raise exception 'RLS missing or disabled for: %', missing;
  end if;
end $$;

do $$
declare policy_count integer;
begin
  select count(*) into policy_count
  from pg_policies
  where schemaname = 'public'
    and tablename in ('families','family_members','family_entries','media_assets','family_invitations');
  if policy_count < 12 then
    raise exception 'Expected at least 12 tenant policies, found %', policy_count;
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'create_family_space' and p.prosecdef
  ) then
    raise exception 'create_family_space security-definer RPC is missing';
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from storage.buckets where id = 'family-media' and public = false
  ) then
    raise exception 'family-media bucket must exist and remain private';
  end if;
end $$;

rollback;
