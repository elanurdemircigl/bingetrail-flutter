enum MediaType { movie, series }

class MediaItem {
  const MediaItem({
    required this.title,
    required this.year,
    required this.genre,
    required this.colorValue,
    required this.type,
    this.progress = 0,
    this.nextEpisode,
  });

  final String title;
  final String year;
  final String genre;
  final int colorValue;
  final MediaType type;
  final double progress;
  final String? nextEpisode;
}
