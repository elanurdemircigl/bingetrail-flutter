abstract final class AppConfig {
  static const tmdbApiReadToken = String.fromEnvironment('TMDB_API_READ_TOKEN');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get hasTmdbToken => tmdbApiReadToken.trim().isNotEmpty;

  static bool get hasSupabaseConfiguration =>
      supabaseUrl.trim().isNotEmpty && supabasePublishableKey.trim().isNotEmpty;
}
