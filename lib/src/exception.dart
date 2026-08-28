import 'code.dart';
import 'version.dart';

/// Everything that can go wrong, with all five fields that cross the C ABI.
///
/// This is `sealed`, so `switch (e) { case YoNotFound(): ... }` is exhaustive
/// and the analyzer names the case you forgot. That is the Dart equivalent of
/// the Swift binding's typed throws, and it beats a bare enum because each
/// subtype can carry fields the others have no use for.
///
/// A binding that flattens this to a message string fails the binding checklist
/// and fails its users too. The multi line [detail] is where the shape diff
/// lives, and a shape diff is the most useful thing this database can hand back
/// when a call fails.
sealed class YoException implements Exception {
  /// Captures the fields every failure carries.
  const YoException({
    required this.message,
    this.position,
    this.detail,
    bool? retryable,
  }) : _retryable = retryable;

  /// What went wrong, as a code that is stable across releases.
  YoCode get code;

  /// One line, in English, saying what happened. Never empty.
  final String message;

  /// Where it happened: a key, a field name, a path, or a byte offset.
  ///
  /// Null when the failure is not attached to a position, which is the case for
  /// things like [YoClosed] and [YoOutOfMemory].
  final String? position;

  /// The long form, when there is one. Multi line, and for a shape mismatch
  /// this is the field by field diff between what was stored and what was asked
  /// for.
  final String? detail;

  final bool? _retryable;

  /// Whether retrying unchanged could plausibly succeed.
  bool get retryable => _retryable ?? code.isRetryable;

  /// The documentation page for this code. Always present.
  ///
  /// Every URL that can appear here is checked by CI against the live
  /// documentation site, so an error never sends a user to a 404.
  Uri get url => Yodb.documentationUrlFor(code);

  /// Renders every field, and truncates none of them.
  ///
  /// Flutter's error console truncates at its own layer and the guide says how
  /// to see the whole thing. A shape mismatch whose diff got cut off is worse
  /// than no diff at all, because it looks like the whole answer.
  @override
  String toString() {
    final buffer = StringBuffer('${code.wireName}: $message');
    if (position != null) {
      buffer.write('\n  at: $position');
    }
    if (detail != null) {
      buffer.write('\n\n$detail');
    }
    buffer.write('\n\nsee: $url');
    return buffer.toString();
  }
}

/// The key, collection or path asked for does not exist.
final class YoNotFound extends YoException {
  /// Reports that the key, collection or path does not exist.
  const YoNotFound({required super.message, super.position, super.detail});

  @override
  YoCode get code => YoCode.notFound;
}

/// The value is there, but it is not the type the operation works on.
final class YoWrongType extends YoException {
  /// Reports an operation applied to the wrong value type.
  const YoWrongType({required super.message, super.position, super.detail});

  @override
  YoCode get code => YoCode.wrongType;
}

/// The type passed does not match the shape stored in the file.
///
/// [detail] carries the field by field diff. Print it.
final class YoShapeMismatch extends YoException {
  /// Reports a stored shape that differs from the requested type.
  const YoShapeMismatch({required super.message, super.position, super.detail});

  @override
  YoCode get code => YoCode.shapeMismatch;
}

/// Another process holds the file.
final class YoLocked extends YoException {
  /// Reports that another process holds the file.
  const YoLocked({required super.message, super.position, super.detail});

  @override
  YoCode get code => YoCode.locked;
}

/// The file failed its integrity check.
final class YoCorrupt extends YoException {
  /// Reports a file that failed its integrity check.
  const YoCorrupt({required super.message, super.position, super.detail});

  @override
  YoCode get code => YoCode.corrupt;
}

/// The handle has been closed and cannot be used again.
final class YoClosed extends YoException {
  /// Reports use of a handle that has already been closed.
  const YoClosed({required super.message, super.position, super.detail});

  @override
  YoCode get code => YoCode.closed;
}

/// The engine ran out of memory.
final class YoOutOfMemory extends YoException {
  /// Reports a failed allocation.
  const YoOutOfMemory({required super.message, super.position, super.detail});

  @override
  YoCode get code => YoCode.outOfMemory;
}

/// The file was written by a newer format version than this build can read.
///
/// This is deliberately a hard failure rather than a best effort read. Opening
/// a file you do not fully understand and returning what you managed to parse
/// is how data gets quietly lost.
final class YoVersionTooNew extends YoException {
  /// Reports a file written by a newer format version than this build reads.
  const YoVersionTooNew({required super.message, super.position, super.detail});

  @override
  YoCode get code => YoCode.versionTooNew;
}

/// Anything the engine reported that this package has no dedicated subtype for.
///
/// A newer engine can return a code this build predates. That is version skew
/// to report accurately, not a reason to throw something misleading, so the
/// original code is carried through untouched.
final class YoUnknownFailure extends YoException {
  /// Wraps a code this build has no dedicated subtype for.
  const YoUnknownFailure({
    required this.code,
    required super.message,
    super.position,
    super.detail,
    super.retryable,
  });

  @override
  final YoCode code;
}
