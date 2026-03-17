import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/helpers.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import '../storage/local_storage_service.dart';

/// Provider that manages the application state for posts
/// Uses ChangeNotifier for reactive state management
class PostProvider with ChangeNotifier {
  final PostRepository _repository;
  final LocalStorageService _storageService;

  // State variables
  List<Post> _posts = [];
  final Set<int> _favoriteIds = {};
  
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  int _currentPage = 0;
  bool _hasMore = true;
  String _searchQuery = '';
  
  bool _isInitialized = false;

  PostProvider({
    required PostRepository repository,
    required LocalStorageService storageService,
  })  : _repository = repository,
        _storageService = storageService;

  // Getters
  List<Post> get posts => _posts;
  Set<int> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  bool get isInitialized => _isInitialized;

  /// Get filtered posts based on search query
  List<Post> get filteredPosts {
    if (_searchQuery.isEmpty) {
      return _posts;
    }
    return _posts.where((post) {
      return Helpers.containsQuery(post.title, _searchQuery);
    }).toList();
  }

  /// Get favorite posts
  List<Post> get favoritePosts {
    return _posts.where((post) => _favoriteIds.contains(post.id)).toList();
  }

  /// Check if a post is favorite
  bool isFavorite(int postId) {
    return _favoriteIds.contains(postId);
  }

  /// Initialize provider - restore favorites and load first page
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Restore favorites from local storage
    _restoreFavorites();
    
    // Load first page of posts
    await loadPosts();
    
    _isInitialized = true;
  }

  /// Restore favorites from local storage
  void _restoreFavorites() {
    try {
      final favorites = _storageService.getFavorites();
      _favoriteIds.addAll(favorites);
    } catch (e) {
      // Silently handle - favorites will be empty
      debugPrint('Failed to restore favorites: $e');
    }
  }

  /// Load posts (initial or next page)
  Future<void> loadPosts({bool loadMore = false}) async {
    if (_isLoading) return;
    if (loadMore && !_hasMore) return;

    _setLoading(true);
    _setError(false, '');

    try {
      final page = loadMore ? _currentPage + 1 : 0;
      final newPosts = await _repository.fetchPosts(page: page);

      if (loadMore) {
        _posts.addAll(newPosts);
        _currentPage++;
      } else {
        _posts = newPosts;
        _currentPage = 0;
      }

      // Check if there are more posts to load
      if (newPosts.length < AppConstants.pageSize) {
        _hasMore = false;
      } else {
        _hasMore = true;
      }

      _setLoading(false);
      notifyListeners();
    } on CacheEmptyException catch (e) {
      debugPrint('CacheEmptyException: $e');
      // This should rarely happen now that we have sample data fallback
      _setError(true, 'Unable to load posts. Please check your internet connection and try again.');
      _setLoading(false);
      notifyListeners();
    } on NetworkException catch (e) {
      debugPrint('NetworkException: $e');
      // Network error - sample data should already be loaded by repository
      if (_posts.isEmpty) {
        _setError(true, 'Network error. Showing offline sample data.\nTap refresh when online to see real posts.');
      }
      _setLoading(false);
      notifyListeners();
    } on AppException catch (e) {
      debugPrint('AppException: $e');
      // API error - sample data should already be loaded
      if (_posts.isEmpty) {
        _setError(true, 'API temporarily unavailable. Showing sample data.\nTap refresh to try again.');
      }
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      debugPrint('Unexpected error in loadPosts: $e');
      if (_posts.isEmpty) {
        _setError(true, 'An error occurred. Showing sample data.\nError: $e');
      }
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Refresh posts (pull-to-refresh)
  Future<void> refreshPosts() async {
    _hasMore = true;
    _currentPage = 0;
    _repository.clearCache();
    
    await loadPosts(loadMore: false);
  }

  /// Update search query and filter posts
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Toggle favorite status of a post
  Future<void> toggleFavorite(int postId) async {
    if (_favoriteIds.contains(postId)) {
      _favoriteIds.remove(postId);
    } else {
      _favoriteIds.add(postId);
    }
    
    // Persist favorites to local storage
    await _saveFavorites();
    
    notifyListeners();
  }

  /// Save favorites to local storage
  Future<void> _saveFavorites() async {
    try {
      await _storageService.saveFavorites(_favoriteIds.toList());
    } catch (e) {
      debugPrint('Failed to save favorites: $e');
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
  }

  /// Set error state
  void _setError(bool hasError, String message) {
    _hasError = hasError;
    _errorMessage = message;
  }

  /// Retry loading after error
  Future<void> retry() async {
    await loadPosts();
  }

  /// Reset provider state
  void reset() {
    _posts = [];
    _currentPage = 0;
    _hasMore = true;
    _searchQuery = '';
    _isLoading = false;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
}
