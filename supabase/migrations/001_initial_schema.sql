-- AdGen Quest: initial protected workspace schema
-- Run once in Supabase SQL Editor after reviewing.
create extension if not exists pgcrypto;

create table if not exists public.team_members (
 user_id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null,
 role text not null default 'member' check (role in ('owner','member')),
 created_at timestamptz not null default now()
);

create or replace function public.is_team_member()
returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.team_members m where m.user_id = auth.uid());
$$;

create table if not exists public.companies (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 website text,
 linkedin_url text,
 country text,
 company_type text,
 priority text default 'P2',
 geo_interest text,
 formats text,
 evidence text,
 owner_id uuid references auth.users(id),
 status text not null default 'Research',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.contacts (
 id uuid primary key default gen_random_uuid(),
 company_id uuid references public.companies(id) on delete set null,
 full_name text not null,
 title text,
 employer text,
 linkedin_url text,
 relationship text not null default 'Unknown',
 source text,
 owner_id uuid references auth.users(id),
 notes text,
 created_at timestamptz not null default now()
);
create table if not exists public.tasks (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 body text,
 company_id uuid references public.companies(id) on delete set null,
 assignee_id uuid references auth.users(id),
 created_by uuid references auth.users(id) default auth.uid(),
 status text not null default 'todo' check(status in ('todo','in_progress','review','done')),
 due_at timestamptz,
 created_at timestamptz not null default now()
);
create table if not exists public.posts (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 body text,
 proposed_by uuid references auth.users(id) default auth.uid(),
 status text not null default 'idea' check(status in ('idea','draft','review','approved','published')),
 published_url text,
 created_at timestamptz not null default now()
);
create table if not exists public.messages (
 id uuid primary key default gen_random_uuid(),
 author_id uuid not null references auth.users(id) default auth.uid(),
 body text not null,
 created_at timestamptz not null default now()
);

alter table public.team_members enable row level security;
alter table public.companies enable row level security;
alter table public.contacts enable row level security;
alter table public.tasks enable row level security;
alter table public.posts enable row level security;
alter table public.messages enable row level security;

drop policy if exists "team members can read team" on public.team_members;
create policy "team members can read team" on public.team_members for select to authenticated using (public.is_team_member());

do $$
declare t text;
begin
 foreach t in array array['companies','contacts','tasks','posts','messages'] loop
  execute format('drop policy if exists "team read" on public.%I',t);
  execute format('create policy "team read" on public.%I for select to authenticated using (public.is_team_member())',t);
  execute format('drop policy if exists "team insert" on public.%I',t);
  execute format('create policy "team insert" on public.%I for insert to authenticated with check (public.is_team_member())',t);
  execute format('drop policy if exists "team update" on public.%I',t);
  execute format('create policy "team update" on public.%I for update to authenticated using (public.is_team_member()) with check (public.is_team_member())',t);
  execute format('drop policy if exists "team delete" on public.%I',t);
  execute format('create policy "team delete" on public.%I for delete to authenticated using (public.is_team_member())',t);
 end loop;
end $$;

-- To activate access: create/authenticate two Supabase Auth users,
-- then add their auth.users IDs to team_members in the SQL editor.
-- Do not create an unrestricted public policy.
