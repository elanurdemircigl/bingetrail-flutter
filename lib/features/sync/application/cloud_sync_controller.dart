import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/application/auth_controller.dart';
import '../../catalog/data/tmdb_client.dart';
import '../../catalog/domain/media_summary.dart';
import '../../progress/application/episode_progress_controller.dart';
import '../../progress/domain/episode_progress.dart';
import '../../watchlist/application/watchlist_controller.dart';

enum CloudSyncStatus { idle, syncing, synced, failed }

class CloudSyncController extends ChangeNotifier {
  CloudSyncController({
    required SupabaseClient supabase,
    required TmdbClient tmdb,
    required AuthController auth,
    required WatchlistController watchlist,
    required EpisodeProgressController episodeProgress,
  }) : _supabase = supabase,
       _tmdb = tmdb,
       _auth = auth,
       _watchlist = watchlist,
       _episodeProgress = episodeProgress;

  final SupabaseClient _supabase;
  final TmdbClient _tmdb;
  final AuthController _auth;
  final WatchlistController _watchlist;
  final EpisodeProgressController _episodeProgress;

  CloudSyncStatus _status = CloudSyncStatus.idle;
  Object? _lastError;
  DateTime? _lastSyncedAt;
  Timer? _pushDebounce;
  String? _activeUserId;
  bool _started = false;
  bool _applyingRemote = false;

  CloudSyncStatus get status => _status;
  Object? get lastError => _lastError;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    _auth.addListener(_onAuthChanged);
    _watchlist.addListener(_onLocalDataChanged);
    _episodeProgress.addListener(_onLocalDataChanged);
    _activeUserId = _auth.user?.id;
    if (_activeUserId != null) {
      await syncNow();
    }
  }

  Future<void> syncNow() async {
    final user = _auth.user;
    if (user == null || _status == CloudSyncStatus.syncing) {
      return;
    }

    _setStatus(CloudSyncStatus.syncing);
    try {
      _applyingRemote = true;
      await _mergeWatchlist(user.id);
      await _mergeEpisodeProgress(user.id);
      _applyingRemote = false;
      await _pushAll(user.id);
      _lastError = null;
      _lastSyncedAt = DateTime.now();
      _setStatus(CloudSyncStatus.synced);
    } on Object catch (error) {
      _applyingRemote = false;
      _lastError = error;
      _setStatus(CloudSyncStatus.failed);
    }
  }

  Future<void> signOut() async {
    final user = _auth.user;
    if (user == null || _status == CloudSyncStatus.syncing) {
      return;
    }
    _pushDebounce?.cancel();
    _setStatus(CloudSyncStatus.syncing);
    try {
      await _pushAll(user.id);
      await _auth.signOut();
    } on Object catch (error) {
      _lastError = error;
      _setStatus(CloudSyncStatus.failed);
      rethrow;
    }
  }

  void _onAuthChanged() {
    final userId = _auth.user?.id;
    if (userId == _activeUserId) {
      return;
    }
    _activeUserId = userId;
    _pushDebounce?.cancel();
    if (userId == null) {
      _lastError = null;
      _lastSyncedAt = null;
      _setStatus(CloudSyncStatus.idle);
      unawaited(_clearLocalAfterSignOut());
    } else {
      unawaited(syncNow());
    }
  }

  Future<void> _clearLocalAfterSignOut() async {
    _applyingRemote = true;
    try {
      await _watchlist.replaceFromSync(const []);
      await _episodeProgress.replaceFromSync(const []);
    } finally {
      _applyingRemote = false;
    }
  }

  void _onLocalDataChanged() {
    if (!_started || _applyingRemote || !_auth.isAuthenticated) {
      return;
    }
    _pushDebounce?.cancel();
    _pushDebounce = Timer(const Duration(milliseconds: 650), () {
      unawaited(_pushLocalChanges());
    });
  }

  Future<void> _pushLocalChanges() async {
    final user = _auth.user;
    if (user == null || _status == CloudSyncStatus.syncing) {
      return;
    }
    _setStatus(CloudSyncStatus.syncing);
    try {
      await _pushAll(user.id);
      _lastError = null;
      _lastSyncedAt = DateTime.now();
      _setStatus(CloudSyncStatus.synced);
    } on Object catch (error) {
      _lastError = error;
      _setStatus(CloudSyncStatus.failed);
    }
  }

  Future<void> _mergeWatchlist(String userId) async {
    final response = await _supabase
        .from('user_media')
        .select('tmdb_id, media_type')
        .eq('user_id', userId);
    final merged = <String, MediaSummary>{
      for (final item in _watchlist.items) item.key: item,
    };

    for (final row in response) {
      final id = row['tmdb_id'] as int;
      final kind = row['media_type'] == 'movie'
          ? MediaKind.movie
          : MediaKind.series;
      final key = '${kind.name}:$id';
      if (!merged.containsKey(key)) {
        merged[key] = await _loadMedia(id, kind);
      }
    }
    await _watchlist.replaceFromSync(merged.values.toList());
  }

  Future<void> _mergeEpisodeProgress(String userId) async {
    final response = await _supabase
        .from('episode_progress')
        .select('tmdb_show_id, season_number, episode_number, watched_at')
        .eq('user_id', userId);
    final watchedBySeries = <int, Set<String>>{};
    final updatedBySeries = <int, DateTime>{};
    final seriesById = <int, MediaSummary>{};

    for (final entry in _episodeProgress.entries) {
      watchedBySeries[entry.series.id] = Set.of(entry.watchedEpisodeKeys);
      updatedBySeries[entry.series.id] = entry.updatedAt;
      seriesById[entry.series.id] = entry.series;
    }
    for (final item in _watchlist.items) {
      if (item.kind == MediaKind.series) {
        seriesById[item.id] = item;
      }
    }

    for (final row in response) {
      final seriesId = row['tmdb_show_id'] as int;
      final key = '${row['season_number']}:${row['episode_number']}';
      watchedBySeries.putIfAbsent(seriesId, () => <String>{}).add(key);
      final watchedAt = DateTime.tryParse(row['watched_at'] as String? ?? '');
      final current = updatedBySeries[seriesId];
      if (watchedAt != null &&
          (current == null || watchedAt.isAfter(current))) {
        updatedBySeries[seriesId] = watchedAt;
      }
    }

    final entries = <EpisodeProgress>[];
    for (final item in watchedBySeries.entries) {
      final series =
          seriesById[item.key] ?? await _loadMedia(item.key, MediaKind.series);
      entries.add(
        EpisodeProgress(
          series: series,
          watchedEpisodeKeys: item.value,
          updatedAt:
              updatedBySeries[item.key] ??
              DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    }
    await _episodeProgress.replaceFromSync(entries);
  }

  Future<MediaSummary> _loadMedia(int id, MediaKind kind) async {
    final placeholder = MediaSummary(
      id: id,
      kind: kind,
      title: 'Loading…',
      overview: '',
      year: '—',
      voteAverage: 0,
    );
    return (await _tmdb.details(placeholder)).summary;
  }

  Future<void> _pushAll(String userId) async {
    await _pushWatchlist(userId);
    await _pushEpisodeProgress(userId);
  }

  Future<void> _pushWatchlist(String userId) async {
    final remote = await _supabase
        .from('user_media')
        .select('tmdb_id, media_type')
        .eq('user_id', userId);
    final localKeys = _watchlist.items
        .map((item) => '${item.kind.name}:${item.id}')
        .toSet();

    for (final row in remote) {
      final remoteType = row['media_type'] as String;
      final remoteId = row['tmdb_id'] as int;
      if (!localKeys.contains('$remoteType:$remoteId')) {
        await _supabase
            .from('user_media')
            .delete()
            .eq('user_id', userId)
            .eq('tmdb_id', remoteId)
            .eq('media_type', remoteType);
      }
    }

    if (_watchlist.items.isNotEmpty) {
      final now = DateTime.now().toIso8601String();
      await _supabase
          .from('user_media')
          .upsert(
            _watchlist.items
                .map(
                  (item) => {
                    'user_id': userId,
                    'tmdb_id': item.id,
                    'media_type': item.kind.name,
                    'status': 'planned',
                    'updated_at': now,
                  },
                )
                .toList(),
            onConflict: 'user_id,tmdb_id,media_type',
          );
    }
  }

  Future<void> _pushEpisodeProgress(String userId) async {
    final localRows = <Map<String, dynamic>>[];
    final localKeys = <String>{};
    for (final entry in _episodeProgress.entries) {
      for (final key in entry.watchedEpisodeKeys) {
        final parts = key.split(':');
        final season = int.parse(parts[0]);
        final episode = int.parse(parts[1]);
        localKeys.add('${entry.series.id}:$season:$episode');
        localRows.add({
          'user_id': userId,
          'tmdb_show_id': entry.series.id,
          'season_number': season,
          'episode_number': episode,
          'watched_at': entry.updatedAt.toIso8601String(),
        });
      }
    }

    final remote = await _supabase
        .from('episode_progress')
        .select('tmdb_show_id, season_number, episode_number')
        .eq('user_id', userId);
    for (final row in remote) {
      final series = row['tmdb_show_id'] as int;
      final season = row['season_number'] as int;
      final episode = row['episode_number'] as int;
      if (!localKeys.contains('$series:$season:$episode')) {
        await _supabase
            .from('episode_progress')
            .delete()
            .eq('user_id', userId)
            .eq('tmdb_show_id', series)
            .eq('season_number', season)
            .eq('episode_number', episode);
      }
    }

    if (localRows.isNotEmpty) {
      await _supabase
          .from('episode_progress')
          .upsert(
            localRows,
            onConflict: 'user_id,tmdb_show_id,season_number,episode_number',
          );
    }
  }

  void _setStatus(CloudSyncStatus value) {
    _status = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _pushDebounce?.cancel();
    if (_started) {
      _auth.removeListener(_onAuthChanged);
      _watchlist.removeListener(_onLocalDataChanged);
      _episodeProgress.removeListener(_onLocalDataChanged);
    }
    super.dispose();
  }
}
