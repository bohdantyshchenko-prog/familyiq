# Connected Platform setup

## 1. Supabase
1. Create a Supabase project.
2. Run `supabase/migrations/20260731_familyiq_core.sql` in the SQL editor or through the Supabase CLI.
3. Confirm the private `family-media` bucket exists.
4. Deploy the `family-brain` Edge Function.
5. Add the Edge Function secrets `OPENAI_API_KEY` and optionally `OPENAI_MODEL`.

## 2. Flutter configuration
Run with compile-time values:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=OPENAI_PROXY_URL=https://YOUR_PROJECT.supabase.co/functions/v1/family-brain
```

The app still starts in local mode when Supabase values are absent.

## 3. Required production work
- Add storage object policies for paths scoped by family membership.
- Add invitation acceptance RPC and owner-only role-management policies.
- Configure email templates, redirect URLs and deep links.
- Add push provider credentials for Android and iOS.
- Replace demo screens with repository-driven streams.
- Add audit logging and deletion/export workflows.

## Security
Never place the OpenAI key in Flutter. It belongs only in Edge Function secrets. The Flutter client receives only the Supabase anonymous key; authorization is enforced by Row Level Security.
