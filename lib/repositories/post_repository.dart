import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/sample_data.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/helpers.dart';
import '../models/post.dart';
import '../services/post_api_service.dart';
import '../storage/local_storage_service.dart';

/// Repository that mediates between the API service and the provider
/// Handles data fetching, caching, and offline fallback logic
class PostRepository {
  final PostApiService _apiService;
  final LocalStorageService _storageService;
  
  // In-memory cache of all posts
  List<Post>? _allPostsCache;

  PostRepository({
    required PostApiService apiService,
    required LocalStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  /// Fetch posts with pagination
  /// Tries API first, falls back to cached data if API fails
  Future<List<Post>> fetchPosts({required int page, int limit = AppConstants.pageSize}) async {
    try {
      debugPrint('PostRepository: Fetching posts (page: $page, limit: $limit)');
      // If we don't have all posts cached in memory, fetch from API
      if (_allPostsCache == null) {
        debugPrint('PostRepository: No in-memory cache, fetching from API...');
        _allPostsCache = await _apiService.fetchAllPosts();
        
        debugPrint('PostRepository: Caching ${_allPostsCache!.length} posts locally...');
        // Cache all posts locally for offline access
        await _storageService.saveCachedPosts(_allPostsCache!);
      }
      
      // Return paginated subset
      final paginatedPosts = Helpers.paginateList(_allPostsCache!, page, limit);
      debugPrint('PostRepository: Returning ${paginatedPosts.length} posts for page $page');
      return paginatedPosts;
    } on AppException catch (e) {
      debugPrint('PostRepository: API exception ($e), falling back to cache...');
      // If API fails, try to load from local cache
      return _fetchCachedPostsPaginated(page, limit);
    } catch (e) {
      debugPrint('PostRepository: Unexpected error ($e), falling back to cache...');
      // For any other error, try cached data
      return _fetchCachedPostsPaginated(page, limit);
    }
  }

  /// Fetch cached posts with pagination
  List<Post> _fetchCachedPostsPaginated(int page, int limit) {
    debugPrint('PostRepository: Attempting to load from local cache...');
    final cachedPosts = _storageService.getCachedPosts();
    
    debugPrint('PostRepository: Found ${cachedPosts.length} cached posts');
    if (cachedPosts.isEmpty) {
      debugPrint('PostRepository: Cache is empty, using sample data as fallback');
      // Use sample data as fallback when no cache and no network
      _allPostsCache = SampleData.samplePosts;
      
      // Note: We can't await here since this is a sync method
      // The sample data will be available immediately anyway
      
      final paginatedPosts = Helpers.paginateList(SampleData.samplePosts, page, limit);
      debugPrint('PostRepository: Returning ${paginatedPosts.length} sample posts for page $page');
      return paginatedPosts;
    }
    
    // Update in-memory cache
    _allPostsCache = cachedPosts;
    
    final paginatedPosts = Helpers.paginateList(cachedPosts, page, limit);
    debugPrint('PostRepository: Returning ${paginatedPosts.length} cached posts for page $page');
    return paginatedPosts;
  }

  /// Get all cached posts (synchronous)
  List<Post> getCachedPosts() {
    return _storageService.getCachedPosts();
  }

  /// Check if posts are cached
  bool hasCachedPosts() {
    return _storageService.hasCachedPosts();
  }

  /// Refresh posts (force fetch from API)
  Future<List<Post>> refreshPosts({int page = 0, int limit = AppConstants.pageSize}) async {
    // Clear in-memory cache to force API call
    _allPostsCache = null;
    return fetchPosts(page: page, limit: limit);
  }

  /// Get total number of posts available
  int getTotalPostsCount() {
    return _allPostsCache?.length ?? _storageService.getCachedPosts().length;
  }

  /// Fetch a single post by ID
  Future<Post?> fetchPostById(int id) async {
    try {
      return await _apiService.fetchPostById(id);
    } catch (e) {
      // Try to find in cache
      final cachedPosts = _storageService.getCachedPosts();
      try {
        return cachedPosts.firstWhere((post) => post.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  /// Clear repository cache
  void clearCache() {
    _allPostsCache = null;
  }
}
