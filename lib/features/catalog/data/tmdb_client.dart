import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../domain/media_details.dart';
import '../domain/media_summary.dart';
import '../domain/tv_season.dart';

class TmdbClient {
  TmdbClient({
    http.Client? client,
    String accessToken = AppConfig.tmdbApiReadToken,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       _accessToken = accessToken.trim();

  static const _host = 'api.themoviedb.org';
  static const _language = 'en-US';

  final http.Client _client;
  final bool _ownsClient;
  final String _accessToken;

  bool get isConfigured => _accessToken.isNotEmpty;

  Future<List<MediaSummary>> trending() async {
    final body = await _get('/3/trending/all/week', {'language': _language});
    return _parseMediaList(body);
  }

  Future<List<MediaSummary>> search(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return trending();
    }

    final body = await _get('/3/search/multi', {
      'query': normalized,
      'include_adult': 'false',
      'language': _language,
      'page': '1',
    });
    return _parseMediaList(body);
  }

  Future<MediaDetails> details(MediaSummary media) async {
    final type = media.kind == MediaKind.movie ? 'movie' : 'tv';
    final body = await _get('/3/$type/${media.id}', {'language': _language});
    return MediaDetails.fromTmdb(body, media.kind);
  }

  Future<TvSeasonDetails> seasonDetails(int seriesId, int seasonNumber) async {
    final body = await _get('/3/tv/$seriesId/season/$seasonNumber', {
      'language': _language,
    });
    return TvSeasonDetails.fromTmdb(body);
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    if (!isConfigured) {
      throw const TmdbConfigurationException();
    }

    final response = await _client.get(
      Uri.https(_host, path, query),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'accept': 'application/json',
      },
    );
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['status_message'] as String?;
      throw TmdbException(
        message ?? 'TMDB request failed (${response.statusCode}).',
      );
    }

    return body;
  }

  List<MediaSummary> _parseMediaList(Map<String, dynamic> body) {
    final results = body['results'] as List<dynamic>? ?? const [];
    final media = <MediaSummary>[];

    for (final item in results.whereType<Map<String, dynamic>>()) {
      final mediaType = item['media_type'];
      if (mediaType != 'movie' && mediaType != 'tv') {
        continue;
      }
      try {
        media.add(MediaSummary.fromTmdb(item));
      } on FormatException {
        continue;
      }
    }

    return media;
  }
}

class TmdbException implements Exception {
  const TmdbException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TmdbConfigurationException extends TmdbException {
  const TmdbConfigurationException()
    : super('Add your TMDB API Read Access Token to load the catalog.');
}
