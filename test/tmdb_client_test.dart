import 'package:bingetrail/features/catalog/data/tmdb_client.dart';
import 'package:bingetrail/features/catalog/domain/media_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('trending parses movies and series while filtering people', () async {
    final client = TmdbClient(
      accessToken: 'test-token',
      client: MockClient((request) async {
        expect(request.url.path, '/3/trending/all/week');
        expect(request.headers['Authorization'], 'Bearer test-token');
        return http.Response(
          '''
          {
            "results": [
              {
                "id": 1,
                "media_type": "movie",
                "title": "Example Movie",
                "overview": "A movie.",
                "release_date": "2026-01-02",
                "vote_average": 8.2,
                "poster_path": "/movie.jpg"
              },
              {
                "id": 2,
                "media_type": "tv",
                "name": "Example Series",
                "overview": "A series.",
                "first_air_date": "2025-03-04",
                "vote_average": 7.4
              },
              {"id": 3, "media_type": "person", "name": "Someone"}
            ]
          }
          ''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final results = await client.trending();

    expect(results, hasLength(2));
    expect(results.first.title, 'Example Movie');
    expect(results.first.kind, MediaKind.movie);
    expect(results.last.title, 'Example Series');
    expect(results.last.kind, MediaKind.series);
  });

  test('missing token fails before sending a request', () async {
    final client = TmdbClient(
      accessToken: '',
      client: MockClient((_) async => http.Response('{}', 200)),
    );

    expect(client.trending, throwsA(isA<TmdbConfigurationException>()));
  });

  test('season details parses episodes in episode order', () async {
    final client = TmdbClient(
      accessToken: 'test-token',
      client: MockClient((request) async {
        expect(request.url.path, '/3/tv/7/season/2');
        return http.Response(
          '''
          {
            "id": 20,
            "name": "Season 2",
            "season_number": 2,
            "episodes": [
              {
                "id": 202,
                "name": "Second",
                "season_number": 2,
                "episode_number": 2,
                "overview": "Two",
                "air_date": "2025-02-02",
                "runtime": 48
              },
              {
                "id": 201,
                "name": "First",
                "season_number": 2,
                "episode_number": 1,
                "overview": "One",
                "air_date": "2025-02-01"
              }
            ]
          }
          ''',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final season = await client.seasonDetails(7, 2);

    expect(season.name, 'Season 2');
    expect(season.episodes, hasLength(2));
    expect(season.episodes.first.code, 'S02 E01');
    expect(season.episodes.last.runtimeMinutes, 48);
  });
}
