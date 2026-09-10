import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/episode_progress.dart';

abstract interface class EpisodeProgressStorage {
  Future<List<EpisodeProgress>> read();

  Future<void> write(List<EpisodeProgress> entries);
}

class SharedPreferencesEpisodeProgressStorage
    implements EpisodeProgressStorage {
  SharedPreferencesEpisodeProgressStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'bingetrail.episode-progress.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<EpisodeProgress>> read() async {
    final rows = await _preferences.getStringList(_key) ?? const [];
    final entries = <EpisodeProgress>[];
    for (final row in rows) {
      try {
        final json = jsonDecode(row);
        if (json is Map<String, dynamic>) {
          entries.add(EpisodeProgress.fromStorage(json));
        }
      } on Object {
        continue;
      }
    }
    return entries;
  }

  @override
  Future<void> write(List<EpisodeProgress> entries) {
    return _preferences.setStringList(
      _key,
      entries.map((entry) => jsonEncode(entry.toStorage())).toList(),
    );
  }
}

class MemoryEpisodeProgressStorage implements EpisodeProgressStorage {
  MemoryEpisodeProgressStorage([List<EpisodeProgress> seed = const []])
    : _entries = List.of(seed);

  List<EpisodeProgress> _entries;

  @override
  Future<List<EpisodeProgress>> read() async => List.of(_entries);

  @override
  Future<void> write(List<EpisodeProgress> entries) async {
    _entries = List.of(entries);
  }
}
