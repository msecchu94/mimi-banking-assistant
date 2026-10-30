/// Base type for expected, application-level failures.
///
/// Use cases return `Either<Failure, T>` (fpdart). Features define concrete
/// failures by extending this type; transport errors and DTOs must be mapped
/// to a [Failure] in the Data layer and never reach Presentation.
abstract class Failure {
  const Failure();
}
