-- Run once in Supabase SQL Editor. AdGen Quest: private Bidster demand history.
create table if not exists public.partner_stats (
  id uuid primary key default gen_random_uuid(),
  period_key text not null,
  advertiser text not null,
  inventory_type text not null default '',
  demand_usd numeric(18,4) not null default 0,
  impressions bigint not null default 0,
  requests bigint not null default 0,
  responses bigint not null default 0,
  source text not null default 'Bidster CRM',
  updated_at timestamptz not null default now(),
  constraint partner_stats_unique unique(period_key, advertiser, inventory_type)
);
create index if not exists partner_stats_period_idx on public.partner_stats(period_key);
alter table public.partner_stats enable row level security;
drop policy if exists "partner stats team read" on public.partner_stats;
create policy "partner stats team read" on public.partner_stats for select to authenticated using (public.is_team_member());
drop policy if exists "partner stats team add" on public.partner_stats;
create policy "partner stats team add" on public.partner_stats for insert to authenticated with check (public.is_team_member());
drop policy if exists "partner stats team update" on public.partner_stats;
create policy "partner stats team update" on public.partner_stats for update to authenticated using (public.is_team_member()) with check (public.is_team_member());
-- Existing contacts, companies and LinkedIn messages are unchanged.
