import 'package:flutter/foundation.dart';

import '../../catalog/domain/media_summary.dart';
import '../../catalog/domain/tv_season.dart';
import '../data/episode_progress_storage.dart';
import '../domain/episode_progress.dart';

class EpisodeProgressController extends ChangeNotifier {
  EpisodeProgressController({EpisodeProgressStorage? storage})
    : _storage = storage ?? SharedPreferencesEpisodeProgressStorage();

  final EpisodeProgressStorage _storage;
  final List<EpisodeProgress> _entries = [];
  bool _isLoaded = false;
  Object? _loadError;

  List<EpisodeProgress> get entries => List.unmodifiable(_entries);
  bool get isLoaded => _isLoaded;
  Object? get loadError => _loadError;

  EpisodeProgress? progressFor(MediaSummary series) {
    for (final entry in _entries) {
      if (entry.series.key == series.key) {
        return entry;
      }
    }
    return null;
  }

  bool isWatched(MediaSummary series, TvEpisode episode) =>
      progressFor(series)?.watchedEpisodeKeys.contains(episode.key) ?? false;

  Set<String> watchedKeysFor(MediaSummary series) =>
      Set.unmodifiable(progressFor(series)?.watchedEpisodeKeys ?? const {});

  Future<void> load() async {
    try {
      final stored = await _storage.read();
      _entries
        ..clear()
        ..addAll(stored);
      _sort();
    } on Object catch (error) {
      _loadError = error;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> toggleEpisode(MediaSummary series, TvEpisode episode) async {
    final previous = List<EpisodeProgress>.of(_entries);
    final existing = progressFor(series);
    final watched = Set<String>.of(existing?.watchedEpisodeKeys ?? const {});

    if (!watched.add(episode.key)) {
      watched.remove(episode.key);
    }
    _entries.removeWhere((entry) => entry.series.key == series.key);
    if (watched.isNotEmpty) {
      _entries.add(
        EpisodeProgress(
          series: series,
          watchedEpisodeKeys: watched,
          updatedAt: DateTime.now(),
        ),
      );
    }
    _sort();
    notifyListeners();

    try {
      await _storage.write(_entries);
    } on Object {
      _entries
        ..clear()
        ..addAll(previous);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> replaceFromSync(List<EpisodeProgress> entries) async {
    _entries
      ..clear()
      ..addAll(entries);
    _sort();
    await _storage.write(_entries);
    notifyListeners();
  }

  void _sort() {
    _entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
