/// Base class for application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? details;
  
  AppException(this.message, [this.details]);
  
  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Exception thrown when network request fails
class NetworkException extends AppException {
  NetworkException([String? details]) 
      : super('Network error occurred', details);
}

/// Exception thrown when API returns an error
class ApiException extends AppException {
  final int? statusCode;
  
  ApiException(super.message, [this.statusCode, super.details]);
}

/// Exception thrown when data parsing fails
class DataParseException extends AppException {
  DataParseException([String? details]) 
      : super('Failed to parse data', details);
}

/// Exception thrown when storage operations fail
class StorageException extends AppException {
  StorageException([String? details]) 
      : super('Storage operation failed', details);
}

/// Exception thrown when cache is empty
class CacheEmptyException extends AppException {
  CacheEmptyException() : super('No cached data available');
}
