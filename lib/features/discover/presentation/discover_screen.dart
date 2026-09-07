import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../catalog/data/tmdb_client.dart';
import '../../catalog/domain/media_summary.dart';
import '../../catalog/presentation/media_details_screen.dart';
import '../../catalog/presentation/widgets/catalog_poster_card.dart';
import '../../catalog/presentation/widgets/tmdb_setup_card.dart';
import '../../watchlist/application/watchlist_controller.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    required this.client,
    required this.watchlist,
    super.key,
  });

  final TmdbClient client;
  final WatchlistController watchlist;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  Future<List<MediaSummary>>? _results;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.client.isConfigured) {
      _results = widget.client.trending();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _runSearch(query);
      }
    });
  }

  void _runSearch(String query) {
    final normalized = query.trim();
    setState(() {
      _activeQuery = normalized;
      _results = widget.client.search(normalized);
    });
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 38),
        children: [
          Text('Discover', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text(
            'Find your next story.',
            style: TextStyle(color: AppTheme.mutedText, fontSize: 16),
          ),
          const SizedBox(height: 26),
          TextField(
            controller: _searchController,
            enabled: widget.client.isConfigured,
            textInputAction: TextInputAction.search,
            onChanged: _onQueryChanged,
            onSubmitted: _runSearch,
            decoration: InputDecoration(
              hintText: widget.client.isConfigured
                  ? 'Search movies and TV series'
                  : 'Connect TMDB to search',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        _runSearch('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 30),
          if (!widget.client.isConfigured)
            const TmdbSetupCard()
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    _activeQuery.isEmpty
                        ? 'Trending This Week'
                        : 'Search Results',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (_activeQuery.isNotEmpty)
                  Text(
                    '“$_activeQuery”',
                    style: const TextStyle(color: AppTheme.mutedText),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            FutureBuilder<List<MediaSummary>>(
              future: _results,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return _SearchError(onRetry: () => _runSearch(_activeQuery));
                }

                final items = snapshot.data ?? const [];
                if (items.isEmpty) {
                  return const _NoResults();
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = switch (constraints.maxWidth) {
                      >= 760 => 5,
                      >= 540 => 4,
                      >= 380 => 3,
                      _ => 2,
                    };
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 22,
                        childAspectRatio: 0.54,
                      ),
                      itemBuilder: (context, index) {
                        final media = items[index];
                        return CatalogPosterCard(
                          media: media,
                          onTap: () => _openDetails(media),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppTheme.coral,
              size: 38,
            ),
            const SizedBox(height: 12),
            const Text('We could not reach the TMDB catalog.'),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, color: AppTheme.mutedText, size: 42),
          SizedBox(height: 12),
          Text('No movies or TV series matched your search.'),
        ],
      ),
    );
  }
}
