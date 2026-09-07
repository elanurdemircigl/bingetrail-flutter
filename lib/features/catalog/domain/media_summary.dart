enum MediaKind { movie, series }

class MediaSummary {
  const MediaSummary({
    required this.id,
    required this.kind,
    required this.title,
    required this.overview,
    required this.year,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
  });

  factory MediaSummary.fromTmdb(
    Map<String, dynamic> json, {
    MediaKind? forcedKind,
  }) {
    final kind = forcedKind ?? _kindFromTmdb(json['media_type'] as String?);
    final rawTitle = kind == MediaKind.movie ? json['title'] : json['name'];
    final rawDate = kind == MediaKind.movie
        ? json['release_date']
        : json['first_air_date'];
    final date = rawDate is String ? rawDate : '';

    return MediaSummary(
      id: json['id'] as int,
      kind: kind,
      title: rawTitle is String && rawTitle.trim().isNotEmpty
          ? rawTitle
          : 'Untitled',
      overview: json['overview'] is String ? json['overview'] as String : '',
      year: date.length >= 4 ? date.substring(0, 4) : '—',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
    );
  }

  factory MediaSummary.fromStorage(Map<String, dynamic> json) {
    return MediaSummary(
      id: json['id'] as int,
      kind: MediaKind.values.byName(json['kind'] as String),
      title: json['title'] as String,
      overview: json['overview'] as String? ?? '',
      year: json['year'] as String? ?? '—',
      voteAverage: (json['voteAverage'] as num?)?.toDouble() ?? 0,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
    );
  }

  final int id;
  final MediaKind kind;
  final String title;
  final String overview;
  final String year;
  final double voteAverage;
  final String? posterPath;
  final String? backdropPath;

  String get key => '${kind.name}:$id';

  String get kindLabel => kind == MediaKind.movie ? 'Movie' : 'TV Series';

  String? get posterUrl =>
      posterPath == null ? null : 'https://image.tmdb.org/t/p/w500$posterPath';

  String? get backdropUrl => backdropPath == null
      ? posterUrl
      : 'https://image.tmdb.org/t/p/w1280$backdropPath';

  Map<String, dynamic> toStorage() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'overview': overview,
    'year': year,
    'voteAverage': voteAverage,
    'posterPath': posterPath,
    'backdropPath': backdropPath,
  };

  static MediaKind _kindFromTmdb(String? value) {
    return switch (value) {
      'movie' => MediaKind.movie,
      'tv' => MediaKind.series,
      _ => throw const FormatException('Unsupported TMDB media type'),
    };
  }
}
