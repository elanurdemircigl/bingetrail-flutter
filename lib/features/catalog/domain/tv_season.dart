class TvSeasonSummary {
  const TvSeasonSummary({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodeCount,
    this.airDate,
    this.posterPath,
  });

  factory TvSeasonSummary.fromTmdb(Map<String, dynamic> json) {
    return TvSeasonSummary(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Season',
      seasonNumber: (json['season_number'] as num).toInt(),
      episodeCount: (json['episode_count'] as num?)?.toInt() ?? 0,
      airDate: json['air_date'] as String?,
      posterPath: json['poster_path'] as String?,
    );
  }

  final int id;
  final String name;
  final int seasonNumber;
  final int episodeCount;
  final String? airDate;
  final String? posterPath;
}

class TvSeasonDetails {
  const TvSeasonDetails({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodes,
  });

  factory TvSeasonDetails.fromTmdb(Map<String, dynamic> json) {
    final episodes =
        (json['episodes'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(TvEpisode.fromTmdb)
            .toList(growable: false)
          ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));

    return TvSeasonDetails(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Season',
      seasonNumber: (json['season_number'] as num).toInt(),
      episodes: episodes,
    );
  }

  final int id;
  final String name;
  final int seasonNumber;
  final List<TvEpisode> episodes;
}

class TvEpisode {
  const TvEpisode({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.overview,
    this.airDate,
    this.runtimeMinutes,
    this.stillPath,
  });

  factory TvEpisode.fromTmdb(Map<String, dynamic> json) {
    return TvEpisode(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Untitled episode',
      seasonNumber: (json['season_number'] as num).toInt(),
      episodeNumber: (json['episode_number'] as num).toInt(),
      overview: json['overview'] as String? ?? '',
      airDate: json['air_date'] as String?,
      runtimeMinutes: (json['runtime'] as num?)?.toInt(),
      stillPath: json['still_path'] as String?,
    );
  }

  final int id;
  final String name;
  final int seasonNumber;
  final int episodeNumber;
  final String overview;
  final String? airDate;
  final int? runtimeMinutes;
  final String? stillPath;

  String get key => '$seasonNumber:$episodeNumber';

  String get code =>
      'S${seasonNumber.toString().padLeft(2, '0')} '
      'E${episodeNumber.toString().padLeft(2, '0')}';

  String? get stillUrl =>
      stillPath == null ? null : 'https://image.tmdb.org/t/p/w500$stillPath';

  bool hasAired([DateTime? reference]) {
    final rawDate = airDate;
    if (rawDate == null || rawDate.isEmpty) {
      return true;
    }
    final date = DateTime.tryParse(rawDate);
    if (date == null) {
      return true;
    }
    final now = reference ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !date.isAfter(today);
  }
}
