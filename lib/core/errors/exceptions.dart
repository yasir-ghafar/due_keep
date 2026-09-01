/// Thrown by the data layer. Presentation maps this to [Failure] copy.
class CacheException implements Exception {
  const CacheException([this.message = 'Could not read the vault.']);

  final String message;

  @override
  String toString() => message;
}
