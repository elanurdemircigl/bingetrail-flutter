import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../watchlist/application/watchlist_controller.dart';
import '../data/tmdb_client.dart';
import '../domain/media_details.dart';
import '../domain/media_summary.dart';
import 'widgets/network_poster.dart';

class MediaDetailsScreen extends StatefulWidget {
  const MediaDetailsScreen({
    required this.media,
    required this.client,
    required this.watchlist,
    super.key,
  });

  final MediaSummary media;
  final TmdbClient client;
  final WatchlistController watchlist;

  @override
  State<MediaDetailsScreen> createState() => _MediaDetailsScreenState();
}

class _MediaDetailsScreenState extends State<MediaDetailsScreen> {
  late final Future<MediaDetails> _details = widget.client.details(
    widget.media,
  );

  Future<void> _toggleWatchlist(MediaSummary media) async {
    try {
      await widget.watchlist.toggle(media);
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The watchlist could not be saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContent(
        maxWidth: 920,
        child: FutureBuilder<MediaDetails>(
          future: _details,
          builder: (context, snapshot) {
            final details = snapshot.data;
            final media = details?.summary ?? widget.media;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 330,
                  pinned: true,
                  stretch: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetworkPoster(
                          imageUrl: media.backdropUrl,
                          iconSize: 58,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, AppTheme.background],
                              stops: [0.35, 1],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 42),
                  sliver: SliverList.list(
                    children: [
                      Text(
                        media.title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        details?.facts ?? '${media.year} · ${media.kindLabel}',
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 15,
                        ),
                      ),
                      if (details != null && details.genres.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: details.genres
                              .map((genre) => Chip(label: Text(genre)))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFC857),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            media.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          AnimatedBuilder(
                            animation: widget.watchlist,
                            builder: (context, _) {
                              final saved = widget.watchlist.contains(media);
                              return FilledButton.icon(
                                onPressed: () => _toggleWatchlist(media),
                                icon: Icon(
                                  saved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_add_outlined,
                                ),
                                label: Text(
                                  saved ? 'In Watchlist' : 'Add to Watchlist',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        media.overview.trim().isEmpty
                            ? 'No overview is available yet.'
                            : media.overview,
                        style: const TextStyle(
                          color: Color(0xFFD2D3DB),
                          fontSize: 16,
                          height: 1.55,
                        ),
                      ),
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) ...[
                        const SizedBox(height: 24),
                        const LinearProgressIndicator(),
                      ],
                      if (snapshot.hasError) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Some extended details could not be loaded.',
                          style: TextStyle(color: AppTheme.coral),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
