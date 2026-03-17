import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/post.dart';

/// Service responsible for local data persistence using SharedPreferences
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  /// Initialize and return LocalStorageService instance
  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  /// Save favorite post IDs
  Future<void> saveFavorites(List<int> favoriteIds) async {
    try {
      await _prefs.setStringList(
        AppConstants.keyFavorites,
        favoriteIds.map((id) => id.toString()).toList(),
      );
    } catch (e) {
      throw StorageException('Failed to save favorites: $e');
    }
  }

  /// Get favorite post IDs
  List<int> getFavorites() {
    try {
      final favorites = _prefs.getStringList(AppConstants.keyFavorites) ?? [];
      return favorites.map((id) => int.parse(id)).toList();
    } catch (e) {
      throw StorageException('Failed to get favorites: $e');
    }
  }

  /// Save cached posts
  Future<void> saveCachedPosts(List<Post> posts) async {
    try {
      final jsonList = posts.map((post) => post.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await _prefs.setString(AppConstants.keyCachedPosts, jsonString);
    } catch (e) {
      throw StorageException('Failed to cache posts: $e');
    }
  }

  /// Get cached posts
  List<Post> getCachedPosts() {
    try {
      final jsonString = _prefs.getString(AppConstants.keyCachedPosts);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      throw StorageException('Failed to get cached posts: $e');
    }
  }

  /// Check if cached posts exist
  bool hasCachedPosts() {
    return _prefs.containsKey(AppConstants.keyCachedPosts);
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await _prefs.remove(AppConstants.keyCachedPosts);
    } catch (e) {
      throw StorageException('Failed to clear cache: $e');
    }
  }

  /// Clear all data including favorites
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw StorageException('Failed to clear all data: $e');
    }
  }
}
