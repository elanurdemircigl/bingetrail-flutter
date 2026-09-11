import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';
import '../features/catalog/data/tmdb_client.dart';
import '../features/progress/application/episode_progress_controller.dart';
import '../features/watchlist/application/watchlist_controller.dart';
import 'app_shell.dart';
import 'theme/app_theme.dart';

class BingeTrailApp extends StatelessWidget {
  const BingeTrailApp({
    super.key,
    this.client,
    this.watchlist,
    this.episodeProgress,
    this.supabaseClient,
  });

  final TmdbClient? client;
  final WatchlistController? watchlist;
  final EpisodeProgressController? episodeProgress;
  final SupabaseClient? supabaseClient;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AppShell(
        client: client,
        watchlist: watchlist,
        episodeProgress: episodeProgress,
        supabaseClient: supabaseClient,
      ),
    );
  }
}
