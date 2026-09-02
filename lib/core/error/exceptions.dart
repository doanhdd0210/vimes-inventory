/// Low-level errors thrown by the data layer (datasources).
///
/// These never cross into the domain/presentation layers directly; the
/// repository implementation catches them and maps them to [Failure]s.
library;

class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final String? statusCode;
}

class CacheException implements Exception {
  const CacheException({required this.message});

  final String message;
}
