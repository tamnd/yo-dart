/// The error codes the engine can return.
///
/// Generated from `errors.toml` in `tamnd/yo` once the release train wires the
/// generator up. The values here are hand written against `dx/02` section 2 and
/// are checked against the published `errors.toml` by CI, so the two cannot
/// drift without a red build.
///
/// Numbers are allocated once and never reused. An integer read from an old
/// file or an old peer still means what it meant when it was written.
enum YoCode {
  /// No failure. Present so the code table matches the C enum exactly.
  ok(0, 'OK'),

  /// The key, collection or path asked for does not exist.
  notFound(1, 'NOT_FOUND'),

  /// The value is there, but it is not the type the operation works on.
  wrongType(2, 'WRONG_TYPE'),

  /// The type passed does not match the shape stored in the file.
  shapeMismatch(3, 'SHAPE_MISMATCH'),

  /// Another process holds the file. The message names the holding pid.
  locked(4, 'LOCKED'),

  /// The file failed its integrity check.
  corrupt(5, 'CORRUPT'),

  /// The operating system refused a read or a write.
  io(6, 'IO'),

  /// The call was well formed but one of its arguments was not usable.
  invalidArgument(7, 'INVALID_ARGUMENT'),

  /// An allocation failed.
  outOfMemory(8, 'OUT_OF_MEMORY'),

  /// The build does not support what was asked for, on this platform.
  unsupported(9, 'UNSUPPORTED'),

  /// The handle has been closed and cannot be used again.
  closed(10, 'CLOSED'),

  /// The call did not finish inside the deadline it was given.
  timeout(11, 'TIMEOUT'),

  /// A reader has held an epoch open long enough to block reclamation.
  epochStalled(12, 'EPOCH_STALLED'),

  /// The file was written by a newer format version than this build reads.
  versionTooNew(13, 'VERSION_TOO_NEW');

  /// Binds a code to its stable integer and its stable wire spelling.
  const YoCode(this.value, this.wireName);

  /// The stable integer, matching `yo_code` in the C header.
  final int value;

  /// The stable screaming snake spelling used by the wire, by the CLI's `--json`
  /// output and by the documentation URLs.
  ///
  /// Dart's own lower camel case is for Dart callers. Everything that crosses a
  /// boundary uses this spelling, so a Dart user grepping a server log for a
  /// code they caught actually finds it.
  final String wireName;

  /// The slug used in this code's documentation URL.
  String get slug => wireName.toLowerCase().replaceAll('_', '-');

  /// Whether retrying the same call unchanged could plausibly succeed.
  ///
  /// This is advice for a retry loop, not a promise. A [timeout] may succeed on
  /// a second attempt. A [shapeMismatch] never will, because nothing about
  /// waiting changes the type the caller passed.
  bool get isRetryable => switch (this) {
    YoCode.locked || YoCode.timeout || YoCode.epochStalled => true,
    _ => false,
  };

  /// Looks a code up by its integer value, which is what comes back across FFI.
  ///
  /// Returns null for a value this build does not know, rather than throwing.
  /// A newer engine paired with an older package is a version skew to report,
  /// not a crash to cause inside an error path.
  static YoCode? fromValue(int value) {
    for (final code in YoCode.values) {
      if (code.value == value) return code;
    }
    return null;
  }
}
