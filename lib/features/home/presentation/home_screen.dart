import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../catalog/data/tmdb_client.dart';
import '../../catalog/domain/media_summary.dart';
import '../../catalog/presentation/media_details_screen.dart';
import '../../catalog/presentation/widgets/catalog_poster_card.dart';
import '../../catalog/presentation/widgets/tmdb_setup_card.dart';
import '../../watchlist/application/watchlist_controller.dart';
import '../data/demo_media.dart';
import '../domain/media_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.client,
    required this.watchlist,
    required this.onDiscover,
    super.key,
  });

  final TmdbClient client;
  final WatchlistController watchlist;
  final VoidCallback onDiscover;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<MediaSummary>> _trending;

  @override
  void initState() {
    super.initState();
    _trending = widget.client.isConfigured
        ? widget.client.trending()
        : Future.value(const []);
  }

  void _openDetails(MediaSummary media) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaDetailsScreen(
          media: media,
          client: widget.client,
          watchlist: widget.watchlist,
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
                const _ContinueWatchingCard(item: DemoMedia.continueWatching),
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
  const _ContinueWatchingCard({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final accent = Color(item.colorValue);

    return Container(
      height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.9), const Color(0xFF24202A)],
        ),
      ),
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
                  color: Colors.black.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'UP NEXT',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              IconButton.filled(
                tooltip: 'Mark episode as watched',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {},
                icon: const Icon(Icons.check_rounded),
              ),
            ],
          ),
          const Spacer(),
          Text(item.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            item.nextEpisode ?? '',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: item.progress,
              minHeight: 5,
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
          ),
        ],
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
