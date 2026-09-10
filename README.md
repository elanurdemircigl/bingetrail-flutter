# BingeTrail

**Every story leaves a trail.**

BingeTrail is a privacy-minded movie and TV tracking app. It is being built with Flutter for Android, iOS, and the web, with Supabase planned for authentication and synchronized user data.

> Current status: interactive MVP with live TMDB discovery, a local watchlist, and device-persistent episode progress.

## What is ready

- Responsive dark-themed Flutter application shell
- Home, Discover, Calendar, and Profile destinations
- Live TMDB trending, search, posters, and movie/TV detail pages
- A persistent local watchlist on mobile and web
- Season and episode lists with watched/unwatched controls
- A real continue-watching card that finds the next aired episode
- Schedule and statistics UI foundations
- Feature-first source layout
- Initial Supabase database migration with row-level security
- Widget smoke tests and GitHub Actions CI
- Android, iOS, and web platform projects

## Planned MVP

- Email, Google, and Apple authentication
- Supabase-backed watchlist synchronization
- Watchlist and viewing statuses
- Account-backed episode progress synchronization
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

First create a TMDB account and obtain an **API Read Access Token**. Copy the safe template:

```powershell
Copy-Item config/dev.example.json config/dev.json
```

Open `config/dev.json`, replace the placeholder with your token, and run:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=config/dev.json
```

`config/dev.json` is ignored by Git. Never commit the real token. The direct client connection is intended for development; use a backend or Supabase Edge Function as a token-hiding proxy before production release.

Run project checks:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Configuration

Copy `.env.example` to `.env` when the Supabase integration is added. Never commit the real `.env` file or service-role keys.

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
