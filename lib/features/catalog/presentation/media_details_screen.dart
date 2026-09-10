import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../progress/application/episode_progress_controller.dart';
import '../../watchlist/application/watchlist_controller.dart';
import '../data/tmdb_client.dart';
import '../domain/media_details.dart';
import '../domain/media_summary.dart';
import '../domain/tv_season.dart';
import 'widgets/network_poster.dart';

class MediaDetailsScreen extends StatefulWidget {
  const MediaDetailsScreen({
    required this.media,
    required this.client,
    required this.watchlist,
    required this.episodeProgress,
    super.key,
  });

  final MediaSummary media;
  final TmdbClient client;
  final WatchlistController watchlist;
  final EpisodeProgressController episodeProgress;

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
                      if (details != null &&
                          media.kind == MediaKind.series) ...[
                        const SizedBox(height: 32),
                        _SeasonTrackingSection(
                          series: media,
                          seasons: details.seasons,
                          client: widget.client,
                          progress: widget.episodeProgress,
                        ),
                      ],
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

class _SeasonTrackingSection extends StatefulWidget {
  const _SeasonTrackingSection({
    required this.series,
    required this.seasons,
    required this.client,
    required this.progress,
  });

  final MediaSummary series;
  final List<TvSeasonSummary> seasons;
  final TmdbClient client;
  final EpisodeProgressController progress;

  @override
  State<_SeasonTrackingSection> createState() => _SeasonTrackingSectionState();
}

class _SeasonTrackingSectionState extends State<_SeasonTrackingSection> {
  int? _selectedSeason;
  Future<TvSeasonDetails>? _seasonDetails;

  @override
  void initState() {
    super.initState();
    if (widget.seasons.isNotEmpty) {
      _selectSeason(widget.seasons.first.seasonNumber, notify: false);
    }
  }

  void _selectSeason(int seasonNumber, {bool notify = true}) {
    void update() {
      _selectedSeason = seasonNumber;
      _seasonDetails = widget.client.seasonDetails(
        widget.series.id,
        seasonNumber,
      );
    }

    if (notify) {
      setState(update);
    } else {
      update();
    }
  }

  Future<void> _toggleEpisode(TvEpisode episode) async {
    try {
      await widget.progress.toggleEpisode(widget.series, episode);
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Episode progress could not be saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seasons.isEmpty) {
      return const Text(
        'Season information is not available yet.',
        style: TextStyle(color: AppTheme.mutedText),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Episode Tracking',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            AnimatedBuilder(
              animation: widget.progress,
              builder: (context, _) => Text(
                '${widget.progress.watchedKeysFor(widget.series).length} watched',
                style: const TextStyle(color: AppTheme.mutedText),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          initialValue: _selectedSeason,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.video_library_outlined),
          ),
          items: widget.seasons
              .map(
                (season) => DropdownMenuItem(
                  value: season.seasonNumber,
                  child: Text(
                    '${season.name} · ${season.episodeCount} episodes',
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) {
              _selectSeason(value);
            }
          },
        ),
        const SizedBox(height: 14),
        FutureBuilder<TvSeasonDetails>(
          future: _seasonDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.cloud_off_rounded,
                    color: AppTheme.coral,
                  ),
                  title: const Text('Episodes could not be loaded.'),
                  trailing: TextButton(
                    onPressed: () => _selectSeason(_selectedSeason!),
                    child: const Text('Retry'),
                  ),
                ),
              );
            }

            final episodes = snapshot.data?.episodes ?? const [];
            if (episodes.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No episodes are available for this season.'),
              );
            }

            return AnimatedBuilder(
              animation: widget.progress,
              builder: (context, _) => Column(
                children: episodes
                    .map((episode) {
                      final aired = episode.hasAired();
                      final watched = widget.progress.isWatched(
                        widget.series,
                        episode,
                      );
                      final metadata = <String>[
                        episode.code,
                        ?episode.airDate,
                        if (episode.runtimeMinutes case final runtime?)
                          '${runtime}m',
                        if (!aired) 'Upcoming',
                      ].join(' · ');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: CheckboxListTile(
                            value: watched,
                            onChanged: aired
                                ? (_) => _toggleEpisode(episode)
                                : null,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              episode.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              metadata,
                              style: const TextStyle(color: AppTheme.mutedText),
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            );
          },
        ),
      ],
    );
  }
}
