-- FamilyIQ 1.7 security hardening.

create or replace function public.is_family_owner(target_family uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.family_members m
    where m.family_id = target_family
      and m.user_id = auth.uid()
      and m.role = 'owner'
  );
$$;

revoke all on function public.is_family_member(uuid) from public;
revoke all on function public.is_family_owner(uuid) from public;
grant execute on function public.is_family_member(uuid) to authenticated;
grant execute on function public.is_family_owner(uuid) to authenticated;

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists family_entries_touch_updated_at on public.family_entries;
create trigger family_entries_touch_updated_at
before update on public.family_entries
for each row execute function public.touch_updated_at();

create table if not exists public.audit_events (
  id bigint generated always as identity primary key,
  family_id uuid references public.families(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null check (char_length(action) between 2 and 80),
  target_type text not null check (char_length(target_type) between 2 and 80),
  target_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.audit_events enable row level security;
create policy "audit owners read" on public.audit_events
for select using (public.is_family_owner(family_id));
create policy "audit members append" on public.audit_events
for insert with check (public.is_family_member(family_id) and actor_id = auth.uid());

create index if not exists family_members_user_family_idx on public.family_members(user_id, family_id);
create index if not exists family_entries_family_created_idx on public.family_entries(family_id, created_at desc);
create index if not exists media_assets_family_entry_idx on public.media_assets(family_id, entry_id);
create index if not exists invitations_family_email_idx on public.family_invitations(family_id, lower(email));
create index if not exists audit_events_family_created_idx on public.audit_events(family_id, created_at desc);

create policy "profiles family members read" on public.profiles
for select using (
  id = auth.uid() or exists (
    select 1
    from public.family_members mine
    join public.family_members theirs on theirs.family_id = mine.family_id
    where mine.user_id = auth.uid() and theirs.user_id = profiles.id
  )
);

create policy "members owner create" on public.family_members
for insert with check (public.is_family_owner(family_id));
create policy "members owner update" on public.family_members
for update using (public.is_family_owner(family_id))
with check (public.is_family_owner(family_id));
create policy "members owner delete" on public.family_members
for delete using (public.is_family_owner(family_id) and user_id <> auth.uid());

create policy "families owner update" on public.families
for update using (public.is_family_owner(id))
with check (public.is_family_owner(id));
create policy "families owner delete" on public.families
for delete using (public.is_family_owner(id));

create policy "media owner delete" on public.media_assets
for delete using (owner_id = auth.uid() or public.is_family_owner(family_id));

create policy "invitations owner create" on public.family_invitations
for insert with check (public.is_family_owner(family_id) and created_by = auth.uid());
create policy "invitations owner update" on public.family_invitations
for update using (public.is_family_owner(family_id))
with check (public.is_family_owner(family_id));
create policy "invitations owner delete" on public.family_invitations
for delete using (public.is_family_owner(family_id));

-- Storage paths must start with the family UUID: familyId/random_file.ext.
create policy "family media members read" on storage.objects
for select to authenticated
using (
  bucket_id = 'family-media'
  and public.is_family_member((storage.foldername(name))[1]::uuid)
);

create policy "family media members upload" on storage.objects
for insert to authenticated
with check (
  bucket_id = 'family-media'
  and public.is_family_member((storage.foldername(name))[1]::uuid)
  and owner_id = auth.uid()
);

create policy "family media owner delete" on storage.objects
for delete to authenticated
using (
  bucket_id = 'family-media'
  and (
    owner_id = auth.uid()
    or public.is_family_owner((storage.foldername(name))[1]::uuid)
  )
);

create or replace function public.create_family_space(family_name text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_family_id uuid;
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;
  if char_length(trim(family_name)) not between 1 and 120 then
    raise exception 'invalid family name';
  end if;

  insert into public.families(name, created_by)
  values (trim(family_name), auth.uid())
  returning id into new_family_id;

  insert into public.family_members(family_id, user_id, role)
  values (new_family_id, auth.uid(), 'owner');

  insert into public.audit_events(family_id, actor_id, action, target_type, target_id)
  values (new_family_id, auth.uid(), 'family.created', 'family', new_family_id::text);

  return new_family_id;
end;
$$;

revoke all on function public.create_family_space(text) from public;
grant execute on function public.create_family_space(text) to authenticated;
