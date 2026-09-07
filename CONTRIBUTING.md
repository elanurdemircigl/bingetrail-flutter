# Contributing to BingeTrail

## Development workflow

1. Create a focused branch such as `feature/tmdb-search`.
2. Keep secrets in `.env`; update `.env.example` only with safe placeholders.
3. Format, analyze, and test before opening a pull request.
4. Keep commits small and use clear messages such as `feat: add watchlist status`.

## Required checks

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Do not commit generated build directories, API secrets, user data, or production database exports.
