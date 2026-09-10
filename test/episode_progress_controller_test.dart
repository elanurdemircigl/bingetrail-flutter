import 'package:bingetrail/features/catalog/domain/media_summary.dart';
import 'package:bingetrail/features/catalog/domain/tv_season.dart';
import 'package:bingetrail/features/progress/application/episode_progress_controller.dart';
import 'package:bingetrail/features/progress/data/episode_progress_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const series = MediaSummary(
    id: 7,
    kind: MediaKind.series,
    title: 'A Series',
    overview: 'Overview',
    year: '2025',
    voteAverage: 8,
  );
  const episode = TvEpisode(
    id: 71,
    name: 'Pilot',
    seasonNumber: 1,
    episodeNumber: 1,
    overview: 'The beginning.',
  );

  test('episode progress persists and can be reversed', () async {
    final storage = MemoryEpisodeProgressStorage();
    final controller = EpisodeProgressController(storage: storage);

    await controller.load();
    await controller.toggleEpisode(series, episode);
    expect(controller.isWatched(series, episode), isTrue);

    final restored = EpisodeProgressController(storage: storage);
    await restored.load();
    expect(restored.isWatched(series, episode), isTrue);
    expect(restored.entries.single.series.title, 'A Series');

    await restored.toggleEpisode(series, episode);
    expect(restored.entries, isEmpty);
  });
}
