import 'package:bingetrail/features/catalog/domain/media_summary.dart';
import 'package:bingetrail/features/watchlist/application/watchlist_controller.dart';
import 'package:bingetrail/features/watchlist/data/watchlist_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const movie = MediaSummary(
    id: 42,
    kind: MediaKind.movie,
    title: 'A Movie',
    overview: 'Overview',
    year: '2026',
    voteAverage: 8,
  );

  test('watchlist loads and persists toggled items', () async {
    final storage = MemoryWatchlistStorage();
    final controller = WatchlistController(storage: storage);

    await controller.load();
    expect(controller.items, isEmpty);

    await controller.toggle(movie);
    expect(controller.contains(movie), isTrue);

    final restored = WatchlistController(storage: storage);
    await restored.load();
    expect(restored.items.single.key, movie.key);

    await restored.toggle(movie);
    expect(restored.items, isEmpty);
  });
}
