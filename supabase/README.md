# Supabase setup

The initial migration models BingeTrail user activity while keeping movie and TV metadata in TMDB.

When a Supabase project is available:

1. Install and authenticate the Supabase CLI.
2. Link this directory to the chosen project.
3. Review the migration and run `supabase db push` yourself.
4. Add the public project URL and anonymous key to the local `.env` file.

Never expose or commit the Supabase service-role key.
