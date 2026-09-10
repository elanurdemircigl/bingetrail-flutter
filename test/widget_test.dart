import 'package:bingetrail/app/app.dart';
import 'package:bingetrail/features/progress/application/episode_progress_controller.dart';
import 'package:bingetrail/features/progress/data/episode_progress_storage.dart';
import 'package:bingetrail/features/watchlist/application/watchlist_controller.dart';
import 'package:bingetrail/features/watchlist/data/watchlist_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the BingeTrail home experience', (tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('BingeTrail'), findsOneWidget);
    expect(find.text('Continue Watching'), findsOneWidget);
    expect(find.text('Your next episode will appear here.'), findsOneWidget);
  });

  testWidgets('moves between primary destinations', (tester) async {
    await tester.pumpWidget(_testApp());

    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Find your next story.'), findsOneWidget);
  });
}

BingeTrailApp _testApp() {
  return BingeTrailApp(
    watchlist: WatchlistController(storage: MemoryWatchlistStorage()),
    episodeProgress: EpisodeProgressController(
      storage: MemoryEpisodeProgressStorage(),
    ),
  );
}
