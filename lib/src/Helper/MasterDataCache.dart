import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MasterDataCache {
  static const Duration defaultTtl = Duration(hours: 24);
  static final Map<String, _MasterDataCacheEntry> _memoryCache = {};
  static final Map<String, Future<List<dynamic>>> _pendingRequests = {};

  static Future<List<dynamic>> getJsonList({
    required String cacheKey,
    required String url,
    Duration ttl = defaultTtl,
    bool forceRefresh = false,
    Map<String, String> headers = const {"Accept": "application/json"},
  }) async {
    final now = DateTime.now();
    final memoryEntry = _memoryCache[cacheKey];
    if (!forceRefresh &&
        memoryEntry != null &&
        now.difference(memoryEntry.savedAt) < ttl) {
      return memoryEntry.data;
    }

    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      final localEntry = _readLocalCache(prefs, cacheKey);
      if (localEntry != null && now.difference(localEntry.savedAt) < ttl) {
        _memoryCache[cacheKey] = localEntry;
        return localEntry.data;
      }
    }

    if (!forceRefresh && _pendingRequests.containsKey(cacheKey)) {
      return _pendingRequests[cacheKey]!;
    }

    final request = _fetchAndCache(
      prefs: prefs,
      cacheKey: cacheKey,
      url: url,
      headers: headers,
    );
    _pendingRequests[cacheKey] = request;

    try {
      return await request;
    } catch (_) {
      final fallbackEntry = _readLocalCache(prefs, cacheKey);
      if (fallbackEntry != null) {
        _memoryCache[cacheKey] = fallbackEntry;
        return fallbackEntry.data;
      }
      rethrow;
    } finally {
      if (_pendingRequests[cacheKey] == request) {
        _pendingRequests.remove(cacheKey);
      }
    }
  }

  static Future<void> clear(String cacheKey) async {
    _memoryCache.remove(cacheKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dataKey(cacheKey));
    await prefs.remove(_timeKey(cacheKey));
  }

  static Future<List<dynamic>> _fetchAndCache({
    required SharedPreferences prefs,
    required String cacheKey,
    required String url,
    required Map<String, String> headers,
  }) async {
    print(url);
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode != 200) {
      throw Exception("Failed to load master data $cacheKey");
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception("Invalid master data response $cacheKey");
    }

    final data = decoded;
    final savedAt = DateTime.now();
    _memoryCache[cacheKey] = _MasterDataCacheEntry(data, savedAt);
    await prefs.setString(_dataKey(cacheKey), response.body);
    await prefs.setInt(_timeKey(cacheKey), savedAt.millisecondsSinceEpoch);
    return data;
  }

  static _MasterDataCacheEntry? _readLocalCache(
    SharedPreferences prefs,
    String cacheKey,
  ) {
    final rawData = prefs.getString(_dataKey(cacheKey));
    final rawTime = prefs.getInt(_timeKey(cacheKey));
    if (rawData == null || rawTime == null) {
      return null;
    }

    final decoded = jsonDecode(rawData);
    if (decoded is! List) {
      return null;
    }

    return _MasterDataCacheEntry(
      decoded,
      DateTime.fromMillisecondsSinceEpoch(rawTime),
    );
  }

  static String _dataKey(String cacheKey) => "master_data_cache_$cacheKey";

  static String _timeKey(String cacheKey) => "master_data_cache_time_$cacheKey";
}

class _MasterDataCacheEntry {
  _MasterDataCacheEntry(this.data, this.savedAt);

  final List<dynamic> data;
  final DateTime savedAt;
}
