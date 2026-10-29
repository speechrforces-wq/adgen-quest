-- Add independent, manually assignable classification facets to contacts.
-- NULL means no manual decision; suggested labels remain provisional.
alter table public.contacts
  add column if not exists traffic_role text,
  add column if not exists industry_group text;
alter table public.contacts
  drop constraint if exists contacts_traffic_role_check;
alter table public.contacts
  add constraint contacts_traffic_role_check check (
    traffic_role is null or traffic_role in ('demand','supply','both','partner','unknown'));
alter table public.contacts
  drop constraint if exists contacts_industry_group_check;
alter table public.contacts
  add constraint contacts_industry_group_check check (
    industry_group is null or industry_group in ('gaming','dsp','ssp','agency','publisher','app_developer','adtech','other'));
-- Existing RLS and conversation records remain unchanged.
