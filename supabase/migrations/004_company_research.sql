-- AdGen Quest: human-reviewed company research with sources
create table if not exists public.company_research (
 company_id uuid primary key references public.companies(id) on delete cascade,
 verdict text not null default 'needs_review' check(verdict in ('needs_review','direct_buyer','agency','intermediary','supply_side','not_fit')),
 summary text not null default '',
 sources text not null default '',
 next_step text not null default '',
 verified_at timestamptz not null default now(),
 updated_by uuid references auth.users(id)
);
alter table public.company_research enable row level security;
drop policy if exists "company research team read" on public.company_research;
create policy "company research team read" on public.company_research for select to authenticated using (public.is_team_member());
drop policy if exists "company research team insert" on public.company_research;
create policy "company research team insert" on public.company_research for insert to authenticated with check (public.is_team_member());
drop policy if exists "company research team update" on public.company_research;
create policy "company research team update" on public.company_research for update to authenticated using (public.is_team_member()) with check (public.is_team_member());
