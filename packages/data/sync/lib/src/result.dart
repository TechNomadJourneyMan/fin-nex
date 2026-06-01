import 'package:pf_domain/pf_domain.dart';
import 'package:meta/meta.dart';

/// Lightweight result type used by sync service calls.
///
/// Prefer this over throwing for control flow that crosses async/isolate
/// boundaries — callers can `switch` on the sealed hierarchy and react.
@immutable
sealed class Result<T, F extends Failure> {
  const Result();

  /// Returns `true` if this is a [Ok].
  bool get isOk => this is Ok<T, F>;

  /// Returns `true` if this is an [Err].
  bool get isErr => this is Err<T, F>;

  /// Unwraps the success value or throws if this is an [Err].
  T unwrap() => switch (this) {
        Ok<T, F>(:final value) => value,
        Err<T, F>(:final failure) =>
          throw StateError('unwrap on Err: $failure'),
      };

  /// Returns the success value, or [fallback] if this is an [Err].
  T unwrapOr(T fallback) => switch (this) {
        Ok<T, F>(:final value) => value,
        Err<T, F>() => fallback,
      };

  /// Maps the success value, leaving failures untouched.
  Result<R, F> map<R>(R Function(T) f) => switch (this) {
        Ok<T, F>(:final value) => Ok<R, F>(f(value)),
        Err<T, F>(:final failure) => Err<R, F>(failure),
      };
}

/// Successful result carrying a value.
@immutable
final class Ok<T, F extends Failure> extends Result<T, F> {
  /// Wraps [value] as success.
  const Ok(this.value);

  /// The success payload.
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Ok<T, F> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Failed result carrying a [Failure].
@immutable
final class Err<T, F extends Failure> extends Result<T, F> {
  /// Wraps [failure] as failure.
  const Err(this.failure);

  /// The failure payload.
  final F failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Err<T, F> && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;
}
