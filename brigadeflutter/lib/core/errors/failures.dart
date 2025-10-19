abstract class Failure {
  final String message;
  const Failure(this.message);
}
class ValidationFailure extends Failure { const ValidationFailure(super.message); }
class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class UnknownFailure extends Failure { const UnknownFailure(super.message); }
