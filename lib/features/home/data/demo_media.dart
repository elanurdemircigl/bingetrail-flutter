import '../domain/media_item.dart';

abstract final class DemoMedia {
  static const continueWatching = MediaItem(
    title: 'Silo',
    year: '2023',
    genre: 'Sci-Fi · Drama',
    colorValue: 0xFF6D5D52,
    type: MediaType.series,
    progress: 0.62,
    nextEpisode: 'S02 E06 · Barricades',
  );

  static const trending = <MediaItem>[
    MediaItem(
      title: 'Severance',
      year: '2022',
      genre: 'Mystery',
      colorValue: 0xFF37637B,
      type: MediaType.series,
    ),
    MediaItem(
      title: 'Dune: Part Two',
      year: '2024',
      genre: 'Sci-Fi',
      colorValue: 0xFF9D6544,
      type: MediaType.movie,
    ),
    MediaItem(
      title: 'The Bear',
      year: '2022',
      genre: 'Drama',
      colorValue: 0xFF5A7049,
      type: MediaType.series,
    ),
  ];

  static const watchlist = <MediaItem>[
    MediaItem(
      title: 'Shōgun',
      year: '2024',
      genre: 'Drama',
      colorValue: 0xFF7C3F36,
      type: MediaType.series,
    ),
    MediaItem(
      title: 'Poor Things',
      year: '2023',
      genre: 'Fantasy',
      colorValue: 0xFF55518B,
      type: MediaType.movie,
    ),
    MediaItem(
      title: 'Fallout',
      year: '2024',
      genre: 'Adventure',
      colorValue: 0xFF88733B,
      type: MediaType.series,
    ),
  ];
}
