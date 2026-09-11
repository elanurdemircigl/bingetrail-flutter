# BingeTrail

**Every story leaves a trail.**

BingeTrail is a privacy-minded movie and TV tracking app. It is being built with Flutter for Android, iOS, and the web, with Supabase planned for authentication and synchronized user data.

> Current status: interactive MVP with live TMDB discovery, account authentication, and Supabase-backed watchlist and episode synchronization.

## What is ready

- Responsive dark-themed Flutter application shell
- Home, Discover, Calendar, and Profile destinations
- Live TMDB trending, search, posters, and movie/TV detail pages
- A persistent local watchlist on mobile and web
- Season and episode lists with watched/unwatched controls
- A real continue-watching card that finds the next aired episode
- Email/password accounts with cloud synchronization through Supabase
- Schedule and statistics UI foundations
- Feature-first source layout
- Initial Supabase database migration with row-level security
- Widget smoke tests and GitHub Actions CI
- Android, iOS, and web platform projects

## Planned MVP

- Google and Apple authentication
- Watchlist and viewing statuses
- Ratings and personal notes
- Release calendar and notifications
- JSON/CSV data export
- Turkish and English localization

## Requirements

- Flutter `3.38.5` or a compatible newer stable release
- Dart `3.10.4` or a compatible version
- Android Studio for Android development
- Xcode on macOS for iOS builds and App Store submission

## Run locally

First obtain a TMDB **API Read Access Token** and create a Supabase project. Copy the safe template:

```powershell
Copy-Item config/dev.example.json config/dev.json
```

Open `config/dev.json`, replace the placeholders with the TMDB token, Supabase project URL, and Supabase publishable key, then run:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=config/dev.json
```

`config/dev.json` is ignored by Git. Never commit the TMDB token or a Supabase secret/service-role key. The Supabase publishable key is intended for client applications and is protected by Row Level Security. The direct TMDB client connection is intended for development; use a backend or Supabase Edge Function as a token-hiding proxy before production release.

Run project checks:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Configuration

The Supabase schema and Row Level Security policies are in `supabase/migrations`. Never place a Supabase secret or service-role key in this client project.

TMDB attribution and licensing requirements must be reviewed before release. BingeTrail is not endorsed or certified by TMDB.

## Project structure

```text
lib/
├── app/                 # App shell and visual theme
├── core/                # Shared constants and infrastructure
└── features/            # Feature-first UI, domain, and data code
supabase/
└── migrations/          # Versioned PostgreSQL schema
docs/                    # Product and engineering decisions
test/                    # Flutter tests
```

## Publishing this project to GitHub

Create an empty `bingetrail` repository on GitHub without a generated README, license, or `.gitignore`. Then run the following commands from this directory yourself:

```bash
git init
git add .
git commit -m "chore: bootstrap BingeTrail"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/bingetrail.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username. No Git or GitHub command has been run automatically for this project.

## License

No open-source license has been selected yet. Keep the repository private unless you intentionally choose and add a license.
