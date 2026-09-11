import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/widgets/responsive_content.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/catalog/data/tmdb_client.dart';
import '../features/discover/presentation/discover_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/progress/application/episode_progress_controller.dart';
import '../features/sync/application/cloud_sync_controller.dart';
import '../features/watchlist/application/watchlist_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({
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
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late final TmdbClient _tmdbClient;
  late final WatchlistController _watchlist;
  late final bool _ownsClient;
  late final bool _ownsWatchlist;
  late final EpisodeProgressController _episodeProgress;
  late final bool _ownsEpisodeProgress;
  AuthController? _auth;
  CloudSyncController? _cloudSync;

  @override
  void initState() {
    super.initState();
    _ownsClient = widget.client == null;
    _ownsWatchlist = widget.watchlist == null;
    _ownsEpisodeProgress = widget.episodeProgress == null;
    _tmdbClient = widget.client ?? TmdbClient();
    _watchlist = widget.watchlist ?? WatchlistController();
    _episodeProgress = widget.episodeProgress ?? EpisodeProgressController();
    final supabase = widget.supabaseClient;
    if (supabase != null) {
      _auth = AuthController(supabase);
      _cloudSync = CloudSyncController(
        supabase: supabase,
        tmdb: _tmdbClient,
        auth: _auth!,
        watchlist: _watchlist,
        episodeProgress: _episodeProgress,
      );
    }
    unawaited(_initializeData());
  }

  Future<void> _initializeData() async {
    await Future.wait([
      if (!_watchlist.isLoaded) _watchlist.load(),
      if (!_episodeProgress.isLoaded) _episodeProgress.load(),
    ]);
    await _cloudSync?.start();
  }

  @override
  void dispose() {
    _cloudSync?.dispose();
    _auth?.dispose();
    if (_ownsClient) {
      _tmdbClient.close();
    }
    if (_ownsWatchlist) {
      _watchlist.dispose();
    }
    if (_ownsEpisodeProgress) {
      _episodeProgress.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(
        client: _tmdbClient,
        watchlist: _watchlist,
        episodeProgress: _episodeProgress,
        onDiscover: () => setState(() => _currentIndex = 1),
      ),
      DiscoverScreen(
        client: _tmdbClient,
        watchlist: _watchlist,
        episodeProgress: _episodeProgress,
      ),
      const CalendarScreen(),
      ProfileScreen(
        watchlist: _watchlist,
        episodeProgress: _episodeProgress,
        auth: _auth,
        cloudSync: _cloudSync,
      ),
    ];

    return Scaffold(
      body: ResponsiveContent(
        child: IndexedStack(index: _currentIndex, children: screens),
      ),
      bottomNavigationBar: ColoredBox(
        color: Theme.of(context).navigationBarTheme.backgroundColor!,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) =>
                  setState(() => _currentIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore_rounded),
                  label: 'Discover',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
