import 'media_summary.dart';
import 'tv_season.dart';

class MediaDetails {
  const MediaDetails({
    required this.summary,
    required this.genres,
    this.runtimeMinutes,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.status,
    this.seasons = const [],
  });

  factory MediaDetails.fromTmdb(Map<String, dynamic> json, MediaKind kind) {
    final genres = (json['genres'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((genre) => genre['name'])
        .whereType<String>()
        .toList(growable: false);
    final episodeRuntimes =
        (json['episode_run_time'] as List<dynamic>? ?? const [])
            .whereType<num>()
            .toList(growable: false);

    return MediaDetails(
      summary: MediaSummary.fromTmdb(json, forcedKind: kind),
      genres: genres,
      runtimeMinutes: kind == MediaKind.movie
          ? (json['runtime'] as num?)?.toInt()
          : episodeRuntimes.isEmpty
          ? null
          : episodeRuntimes.first.toInt(),
      numberOfSeasons: (json['number_of_seasons'] as num?)?.toInt(),
      numberOfEpisodes: (json['number_of_episodes'] as num?)?.toInt(),
      status: json['status'] as String?,
      seasons:
          (json['seasons'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(TvSeasonSummary.fromTmdb)
              .where((season) => season.seasonNumber > 0)
              .toList(growable: false)
            ..sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber)),
    );
  }

  final MediaSummary summary;
  final List<String> genres;
  final int? runtimeMinutes;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? status;
  final List<TvSeasonSummary> seasons;

  String get facts {
    final parts = <String>[summary.year, summary.kindLabel];
    if (runtimeMinutes case final minutes?) {
      parts.add('${minutes}m');
    }
    if (numberOfSeasons case final seasons?) {
      parts.add('$seasons season${seasons == 1 ? '' : 's'}');
    }
    return parts.join(' · ');
  }
}
