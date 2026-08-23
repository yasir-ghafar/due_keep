/// Domain-level failure. Presentation maps these to copy; data maps
/// exceptions into these. Never leak storage or platform types upward.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read the vault.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'That item is not in the vault.']);
}
