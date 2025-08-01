import 'package:dartz/dartz.dart';
import 'package:health_connect/core/error/failures.dart';

// This is the abstract base class that all use cases will implement.
// It defines a standard contract for a use case.
abstract class UseCase<Type, Params> {
  /// The main method of a use case.
  /// It takes [params] and returns a Future of Either a [Failure] or the [Type].
  Future<Either<Failure, Type>> call(Params params);
}

/// A special class to represent "no parameters" for use cases that don't need any.
class NoParams {}