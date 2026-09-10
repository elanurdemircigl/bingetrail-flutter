import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../catalog/data/tmdb_client.dart';
import '../../catalog/domain/media_summary.dart';
import '../../catalog/domain/tv_season.dart';
import '../../catalog/presentation/media_details_screen.dart';
import '../../catalog/presentation/widgets/catalog_poster_card.dart';
import '../../catalog/presentation/widgets/network_poster.dart';
import '../../catalog/presentation/widgets/tmdb_setup_card.dart';
import '../../progress/application/episode_progress_controller.dart';
import '../../progress/domain/episode_progress.dart';
import '../../watchlist/application/watchlist_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.client,
    required this.watchlist,
    required this.episodeProgress,
    required this.onDiscover,
    super.key,
  });

  final TmdbClient client;
  final WatchlistController watchlist;
  final EpisodeProgressController episodeProgress;
  final VoidCallback onDiscover;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<MediaSummary>> _trending;
  late Future<_ContinueWatchingData?> _continueWatching;

  @override
  void initState() {
    super.initState();
    _trending = widget.client.isConfigured
        ? widget.client.trending()
        : Future.value(const []);
    _continueWatching = _resolveContinueWatching();
    widget.episodeProgress.addListener(_refreshContinueWatching);
  }

  @override
  void dispose() {
    widget.episodeProgress.removeListener(_refreshContinueWatching);
    super.dispose();
  }

  void _refreshContinueWatching() {
    if (mounted) {
      setState(() {
        _continueWatching = _resolveContinueWatching();
      });
    }
  }

  Future<_ContinueWatchingData?> _resolveContinueWatching() async {
    if (!widget.client.isConfigured ||
        !widget.episodeProgress.isLoaded ||
        widget.episodeProgress.entries.isEmpty) {
      return null;
    }

    for (final progress in widget.episodeProgress.entries) {
      final details = await widget.client.details(progress.series);
      for (final season in details.seasons) {
        final seasonDetails = await widget.client.seasonDetails(
          progress.series.id,
          season.seasonNumber,
        );
        for (final episode in seasonDetails.episodes) {
          if (episode.hasAired() &&
              !progress.watchedEpisodeKeys.contains(episode.key)) {
            final total = details.numberOfEpisodes ?? 0;
            final ratio = total == 0
                ? 0.0
                : (progress.watchedEpisodeKeys.length / total)
                      .clamp(0.0, 1.0)
                      .toDouble();
            return _ContinueWatchingData(
              progress: progress,
              nextEpisode: episode,
              completion: ratio,
            );
          }
        }
      }
    }
    return null;
  }

  void _openDetails(MediaSummary media) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaDetailsScreen(
          media: media,
          client: widget.client,
          watchlist: widget.watchlist,
          episodeProgress: widget.episodeProgress,
        ),
      ),
    );
  }

  void _retryTrending() {
    setState(() => _trending = widget.client.trending());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            sliver: SliverList.list(
              children: [
                const _Header(),
                const SizedBox(height: 26),
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: 'Search movies, shows and people',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onTap: widget.onDiscover,
                ),
                const SizedBox(height: 30),
                const _SectionHeader(title: 'Continue Watching'),
                const SizedBox(height: 14),
                FutureBuilder<_ContinueWatchingData?>(
                  future: _continueWatching,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _ContinueWatchingLoading();
                    }
                    if (snapshot.hasError) {
                      return _ContinueWatchingError(
                        onRetry: _refreshContinueWatching,
                      );
                    }
                    final data = snapshot.data;
                    if (data == null) {
                      return _EmptyContinueWatching(
                        onDiscover: widget.onDiscover,
                      );
                    }
                    return _ContinueWatchingCard(
                      data: data,
                      onOpen: () => _openDetails(data.progress.series),
                      onMarkWatched: () => widget.episodeProgress.toggleEpisode(
                        data.progress.series,
                        data.nextEpisode,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                _SectionHeader(
                  title: 'Trending This Week',
                  action: 'Discover',
                  onAction: widget.onDiscover,
                ),
                const SizedBox(height: 16),
                if (!widget.client.isConfigured)
                  const TmdbSetupCard(compact: true)
                else
                  FutureBuilder<List<MediaSummary>>(
                    future: _trending,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _LoadingStrip();
                      }
                      if (snapshot.hasError) {
                        return _CatalogError(onRetry: _retryTrending);
                      }
                      return _HorizontalCatalogList(
                        items: snapshot.data ?? const [],
                        onOpen: _openDetails,
                      );
                    },
                  ),
                const SizedBox(height: 32),
                const _SectionHeader(title: 'Your Watchlist'),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: widget.watchlist,
                  builder: (context, _) {
                    if (!widget.watchlist.isLoaded) {
                      return const _LoadingStrip();
                    }
                    if (widget.watchlist.items.isEmpty) {
                      return _EmptyWatchlist(onDiscover: widget.onDiscover);
                    }
                    return _HorizontalCatalogList(
                      items: widget.watchlist.items,
                      onOpen: _openDetails,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.coral, AppTheme.violet],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.play_arrow_rounded, size: 28),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
              ),
              Text(
                AppConstants.tagline,
                style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class _ContinueWatchingCard extends StatelessWidget {
  const _ContinueWatchingCard({
    required this.data,
    required this.onOpen,
    required this.onMarkWatched,
  });

  final _ContinueWatchingData data;
  final VoidCallback onOpen;
  final Future<void> Function() onMarkWatched;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 190,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkPoster(imageUrl: data.progress.series.backdropUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xB5090A0F), Color(0xF024202A)],
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpen,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.42),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'UP NEXT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton.filled(
                            tooltip: 'Mark episode as watched',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: onMarkWatched,
                            icon: const Icon(Icons.check_rounded),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        data.progress.series.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.nextEpisode.code} · ${data.nextEpisode.name}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: data.completion,
                          minHeight: 5,
                          color: Colors.white,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueWatchingData {
  const _ContinueWatchingData({
    required this.progress,
    required this.nextEpisode,
    required this.completion,
  });

  final EpisodeProgress progress;
  final TvEpisode nextEpisode;
  final double completion;
}

class _ContinueWatchingLoading extends StatelessWidget {
  const _ContinueWatchingLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 150,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyContinueWatching extends StatelessWidget {
  const _EmptyContinueWatching({required this.onDiscover});

  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: const Icon(Icons.play_circle_outline_rounded),
        title: const Text('Your next episode will appear here.'),
        subtitle: const Text(
          'Open a TV series and mark an episode as watched.',
        ),
        trailing: TextButton(
          onPressed: onDiscover,
          child: const Text('Explore'),
        ),
      ),
    );
  }
}

class _ContinueWatchingError extends StatelessWidget {
  const _ContinueWatchingError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.cloud_off_rounded, color: AppTheme.coral),
        title: const Text('Your next episode could not be loaded.'),
        trailing: TextButton(onPressed: onRetry, child: const Text('Retry')),
      ),
    );
  }
}

class _HorizontalCatalogList extends StatelessWidget {
  const _HorizontalCatalogList({required this.items, required this.onOpen});

  final List<MediaSummary> items;
  final ValueChanged<MediaSummary> onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 90,
        child: Center(child: Text('Nothing to show yet.')),
      );
    }

    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final media = items[index];
          return CatalogPosterCard(
            media: media,
            width: 142,
            onTap: () => onOpen(media),
          );
        },
      ),
    );
  }
}

class _LoadingStrip extends StatelessWidget {
  const _LoadingStrip();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 150,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.cloud_off_rounded, color: AppTheme.coral),
        title: const Text('The catalog could not be loaded'),
        trailing: TextButton(onPressed: onRetry, child: const Text('Retry')),
      ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist({required this.onDiscover});

  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.bookmark_border_rounded, color: AppTheme.violet),
            const SizedBox(width: 14),
            const Expanded(
              child: Text('Save a title and it will stay here on this device.'),
            ),
            TextButton(onPressed: onDiscover, child: const Text('Explore')),
          ],
        ),
      ),
    );
  }
}
