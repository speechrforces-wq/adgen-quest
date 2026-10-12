-- AdGen Quest LinkedIn conversation history
create table if not exists public.linkedin_messages (
  id uuid primary key default gen_random_uuid(),
  fingerprint text not null unique,
  conversation_id text,
  sender text not null,
  recipient text,
  sender_profile_url text,
  recipient_profile_urls text,
  sent_at timestamptz,
  body text not null default '',
  imported_at timestamptz not null default now()
);
create index if not exists linkedin_messages_sent_at_idx on public.linkedin_messages(sent_at desc);
create index if not exists linkedin_messages_conversation_idx on public.linkedin_messages(conversation_id);
alter table public.linkedin_messages enable row level security;
drop policy if exists "linkedin history select" on public.linkedin_messages;
create policy "linkedin history select" on public.linkedin_messages for select to authenticated using (public.is_team_member());
drop policy if exists "linkedin history insert" on public.linkedin_messages;
create policy "linkedin history insert" on public.linkedin_messages for insert to authenticated with check (public.is_team_member());
-- This migration does not delete any messages or existing contacts.
