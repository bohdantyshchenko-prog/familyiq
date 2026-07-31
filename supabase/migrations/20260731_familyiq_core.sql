create extension if not exists pgcrypto;

create type public.family_role as enum ('owner','adult','child','relative');
create type public.entry_type as enum ('memory','event','project','task','note');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  avatar_url text,
  created_at timestamptz not null default now()
);

create table public.families (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.family_members (
  family_id uuid not null references public.families(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.family_role not null default 'adult',
  joined_at timestamptz not null default now(),
  primary key (family_id,user_id)
);

create table public.family_entries (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  author_id uuid not null references public.profiles(id),
  type public.entry_type not null,
  title text not null check (char_length(title) between 1 and 160),
  note text not null default '',
  starts_at timestamptz,
  due_at timestamptz,
  completed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.media_assets (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  entry_id uuid references public.family_entries(id) on delete cascade,
  owner_id uuid not null references public.profiles(id),
  storage_path text not null unique,
  mime_type text not null,
  created_at timestamptz not null default now()
);

create table public.family_invitations (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  email text not null,
  role public.family_role not null default 'adult',
  token_hash text not null unique,
  expires_at timestamptz not null,
  accepted_at timestamptz,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

create or replace function public.is_family_member(target_family uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.family_members m where m.family_id = target_family and m.user_id = auth.uid());
$$;

alter table public.profiles enable row level security;
alter table public.families enable row level security;
alter table public.family_members enable row level security;
alter table public.family_entries enable row level security;
alter table public.media_assets enable row level security;
alter table public.family_invitations enable row level security;

create policy "profiles self read" on public.profiles for select using (id = auth.uid());
create policy "profiles self update" on public.profiles for update using (id = auth.uid());
create policy "families members read" on public.families for select using (public.is_family_member(id));
create policy "families authenticated create" on public.families for insert with check (created_by = auth.uid());
create policy "members family read" on public.family_members for select using (public.is_family_member(family_id));
create policy "entries family read" on public.family_entries for select using (public.is_family_member(family_id));
create policy "entries family create" on public.family_entries for insert with check (public.is_family_member(family_id) and author_id = auth.uid());
create policy "entries author update" on public.family_entries for update using (author_id = auth.uid());
create policy "entries author delete" on public.family_entries for delete using (author_id = auth.uid());
create policy "media family read" on public.media_assets for select using (public.is_family_member(family_id));
create policy "media owner create" on public.media_assets for insert with check (public.is_family_member(family_id) and owner_id = auth.uid());
create policy "invitations family read" on public.family_invitations for select using (public.is_family_member(family_id));

insert into storage.buckets (id,name,public) values ('family-media','family-media',false) on conflict (id) do nothing;
