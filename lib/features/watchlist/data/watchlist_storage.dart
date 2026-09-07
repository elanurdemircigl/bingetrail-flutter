import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../catalog/domain/media_summary.dart';

abstract interface class WatchlistStorage {
  Future<List<MediaSummary>> read();

  Future<void> write(List<MediaSummary> items);
}

class SharedPreferencesWatchlistStorage implements WatchlistStorage {
  SharedPreferencesWatchlistStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'bingetrail.watchlist.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<MediaSummary>> read() async {
    final rows = await _preferences.getStringList(_key) ?? const [];
    final items = <MediaSummary>[];

    for (final row in rows) {
      try {
        final json = jsonDecode(row);
        if (json is Map<String, dynamic>) {
          items.add(MediaSummary.fromStorage(json));
        }
      } on FormatException {
        continue;
      }
    }

    return items;
  }

  @override
  Future<void> write(List<MediaSummary> items) {
    final rows = items.map((item) => jsonEncode(item.toStorage())).toList();
    return _preferences.setStringList(_key, rows);
  }
}

class MemoryWatchlistStorage implements WatchlistStorage {
  MemoryWatchlistStorage([List<MediaSummary> seed = const []])
    : _items = List.of(seed);

  List<MediaSummary> _items;

  @override
  Future<List<MediaSummary>> read() async => List.of(_items);

  @override
  Future<void> write(List<MediaSummary> items) async {
    _items = List.of(items);
  }
}
