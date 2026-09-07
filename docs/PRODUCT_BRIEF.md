# BingeTrail product brief

## Product promise

BingeTrail helps people remember, organize, and understand everything they watch while keeping their viewing history portable.

## Primary user

A streaming viewer who follows several shows at once, forgets the last episode watched, and keeps an unstructured list of recommendations across multiple services.

## MVP jobs

1. Find a movie or show quickly.
2. Add it to a meaningful status: planned, watching, completed, paused, or dropped.
3. Mark an episode as watched with one action.
4. See the next episode and upcoming releases.
5. Export the complete viewing history without contacting support.

## Product principles

- **Fast:** common tracking actions take one or two taps.
- **Portable:** users can export all personal activity as JSON or CSV.
- **Spoiler-safe:** future community content is hidden until the matching episode is watched.
- **Sustainable:** infrastructure-heavy social features are introduced only with a moderation and funding plan.
- **Original:** the brand and interface solve the same need as earlier trackers without copying their protected identity or design.

## Not in the first release

- Public comments and direct messaging
- Automatic streaming-history scraping
- AI recommendations
- Video streaming or copyrighted media hosting

## Development configuration

The Flutter client receives the TMDB API Read Access Token through `--dart-define-from-file=config/dev.json`. That local file is excluded from version control. A backend proxy is required before production so the credential is not shipped in the client bundle.
