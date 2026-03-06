class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'An unexpected server error occurred.']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache operation failed.']);

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication error.']);

  @override
  String toString() => 'AuthException: $message';
}
