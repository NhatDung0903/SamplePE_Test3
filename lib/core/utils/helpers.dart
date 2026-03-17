import 'dart:convert';

/// Utility helper functions
class Helpers {
  /// Safely decode JSON string to dynamic object
  static dynamic decodeJson(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      return null;
    }
  }
  
  /// Safely encode object to JSON string
  static String? encodeJson(dynamic object) {
    try {
      return json.encode(object);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if string contains search query (case-insensitive)
  static bool containsQuery(String text, String query) {
    if (query.isEmpty) return true;
    return text.toLowerCase().contains(query.toLowerCase());
  }
  
  /// Truncate text to specific length with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Get paginated subset of a list
  static List<T> paginateList<T>(List<T> list, int page, int pageSize) {
    final startIndex = page * pageSize;
    if (startIndex >= list.length) return [];
    
    final endIndex = (startIndex + pageSize).clamp(0, list.length);
    return list.sublist(startIndex, endIndex);
  }
}
