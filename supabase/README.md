# Supabase setup

The initial migration models BingeTrail user activity while keeping movie and TV metadata in TMDB.

When a Supabase project is available:

1. Install and authenticate the Supabase CLI.
2. Link this directory to the chosen project.
3. Review the migration and run `supabase db push` yourself.
4. Add the project URL and publishable key to the ignored `config/dev.json` file.

The publishable key is intended for client applications. Never expose or commit a Supabase secret or service-role key.
