import '../error/failures.dart';

/// Represents the result of an operation that can either succeed or fail
sealed class Result<T> {
  const Result();

  /// Execute different actions based on the result type
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Error<T>(:final failure) => error(failure),
    };
  }

  /// Returns true if the result is a success
  bool get isSuccess => this is Success<T>;

  /// Returns true if the result is an error
  bool get isError => this is Error<T>;

  /// Get the data if success, null otherwise
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Error<T>() => null,
  };

  /// Get the failure if error, null otherwise
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Error<T>(:final failure) => failure,
  };
}

/// Represents a successful result
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success: $data';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Represents a failed result
class Error<T> extends Result<T> {
  final Failure failure;

  const Error(this.failure);

  @override
  String toString() => 'Error: $failure';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Map the success value to another type
  Result<R> map<R>(R Function(T) mapper) {
    return when(
      success: (data) => Success(mapper(data)),
      error: (failure) => Error<R>(failure),
    );
  }

  /// Chain another operation that returns a Result
  Result<R> flatMap<R>(Result<R> Function(T) mapper) {
    return when(
      success: (data) => mapper(data),
      error: (failure) => Error<R>(failure),
    );
  }
}
