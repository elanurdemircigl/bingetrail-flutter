import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../features/catalog/data/tmdb_client.dart';
import '../features/watchlist/application/watchlist_controller.dart';
import 'app_shell.dart';
import 'theme/app_theme.dart';

class BingeTrailApp extends StatelessWidget {
  const BingeTrailApp({super.key, this.client, this.watchlist});

  final TmdbClient? client;
  final WatchlistController? watchlist;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AppShell(client: client, watchlist: watchlist),
    );
  }
}
