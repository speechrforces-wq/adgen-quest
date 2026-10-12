# AI company research setup

The app's **AI-исследование сайта и рынка** button sends the authenticated user session and company ID to Supabase Edge Function `research-company`. AI keys must **never** appear in `index.html`, browser localStorage, GitHub commits, or Supabase public tables.

## Deployment

1. In Supabase dashboard open **Edge Functions → Deploy a new function → Via Editor** (or use Supabase CLI).
2. Create a function with the exact name `research-company`. Paste the code in [supabase/functions/research-company/index.ts](./supabase/functions/research-company/index.ts).
3. Keep **Verify JWT** enabled. The function independently verifies the logged-in user and team membership.
4. Go to **Edge Functions → Secrets**, set `OPENAI_API_KEY` to your own valid OpenAI API key. Do not paste the secret in ChatGPT or GitHub.
5. Deploy, open Quest, choose a company, press **🧠 AI-исследование сайта и рынка**.
6. Verify the suggested source links and conclusions. The output is intentionally **not saved automatically**: click **💾 Сохранить исследование** after review.

The feature requires an OpenAI API account with paid usage available. Supabase Edge Functions also have runtime/time limits; broad research could time out. If that happens, retry or move research to an async job. Set usage budget and monitor API costs. The function uses OpenAI Responses API with web search. Company names and existing company descriptions are sent to the AI provider; never send private partner financial statistics or personal conversations.

`company_research` is created by migration `004_company_research.sql`, and is subject to team-member RLS.
