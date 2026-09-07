abstract final class AppConfig {
  static const tmdbApiReadToken = String.fromEnvironment('TMDB_API_READ_TOKEN');

  static bool get hasTmdbToken => tmdbApiReadToken.trim().isNotEmpty;
}
