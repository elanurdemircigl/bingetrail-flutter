import '../../catalog/domain/media_summary.dart';

class EpisodeProgress {
  const EpisodeProgress({
    required this.series,
    required this.watchedEpisodeKeys,
    required this.updatedAt,
  });

  factory EpisodeProgress.fromStorage(Map<String, dynamic> json) {
    return EpisodeProgress(
      series: MediaSummary.fromStorage(
        Map<String, dynamic>.from(json['series'] as Map),
      ),
      watchedEpisodeKeys: Set<String>.from(
        (json['watchedEpisodeKeys'] as List<dynamic>? ?? const [])
            .whereType<String>(),
      ),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final MediaSummary series;
  final Set<String> watchedEpisodeKeys;
  final DateTime updatedAt;

  Map<String, dynamic> toStorage() => {
    'series': series.toStorage(),
    'watchedEpisodeKeys': watchedEpisodeKeys.toList()..sort(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
