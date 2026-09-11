import 'package:flutter/foundation.dart';

import '../../catalog/domain/media_summary.dart';
import '../data/watchlist_storage.dart';

class WatchlistController extends ChangeNotifier {
  WatchlistController({WatchlistStorage? storage})
    : _storage = storage ?? SharedPreferencesWatchlistStorage();

  final WatchlistStorage _storage;
  final List<MediaSummary> _items = [];
  bool _isLoaded = false;
  Object? _loadError;

  List<MediaSummary> get items => List.unmodifiable(_items);
  bool get isLoaded => _isLoaded;
  Object? get loadError => _loadError;

  bool contains(MediaSummary media) =>
      _items.any((item) => item.key == media.key);

  Future<void> load() async {
    try {
      final stored = await _storage.read();
      _items
        ..clear()
        ..addAll(stored);
    } on Object catch (error) {
      _loadError = error;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> toggle(MediaSummary media) async {
    final previous = List<MediaSummary>.of(_items);
    if (contains(media)) {
      _items.removeWhere((item) => item.key == media.key);
    } else {
      _items.insert(0, media);
    }
    notifyListeners();

    try {
      await _storage.write(_items);
    } on Object {
      _items
        ..clear()
        ..addAll(previous);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> replaceFromSync(List<MediaSummary> items) async {
    _items
      ..clear()
      ..addAll(items);
    await _storage.write(_items);
    notifyListeners();
  }
}
