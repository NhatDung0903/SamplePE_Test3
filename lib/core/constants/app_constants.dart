/// Application-wide constants
class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String postsEndpoint = '/posts';
  
  // Pagination
  static const int pageSize = 10;
  
  // SharedPreferences Keys
  static const String keyFavorites = 'favorite_posts';
  static const String keyCachedPosts = 'cached_posts';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // UI Constants
  static const int maxBodyPreviewLines = 2;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  
  // Messages
  static const String errorMessageGeneric = 'Something went wrong. Please try again.';
  static const String errorMessageNetwork = 'Network error. Please check your connection.';
  static const String emptyStateMessage = 'No posts available';
  static const String emptyFavoritesMessage = 'No favorites yet';
  static const String emptySearchMessage = 'No posts found for your search';
}
