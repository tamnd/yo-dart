import 'code.dart';

/// The package's own constants, and the things that are true before an engine
/// is loaded.
///
/// There is no database here yet. The native library is built by the release
/// train in `tamnd/yo` and vendored into this package per platform once M1
/// lands a record plane, and the typed collection API arrives with it. What is
/// here today is the error surface and the version contract, which are the
/// parts that do not need the engine to exist and which everything else is
/// built on top of.
abstract final class Yodb {
  /// The version of this package.
  ///
  /// Every tier 1 and tier 2 SDK shares one version number with the engine. A
  /// binding does not get its own version line, because a user asking "which
  /// yodb do I need for yo 1.4" is a question the project inflicted on itself.
  static const String version = '0.0.0';

  /// The C ABI version this package is built against.
  ///
  /// Separate from [version] and much slower moving. It is frozen at M6 and a
  /// minor release never bumps it.
  static const int abiVersion = 0;

  /// The on disk format version this package can open.
  ///
  /// Also separate, also frozen at M6. A file written by a newer format version
  /// fails to open with [YoCode.versionTooNew] rather than being read wrongly.
  static const int formatVersion = 0;

  /// Where the documentation lives.
  static final Uri documentationHost = Uri.parse('https://yo.tamnd.dev');

  /// The documentation page for an error code.
  static Uri documentationUrlFor(YoCode code) =>
      documentationHost.resolve('/errors/${code.slug}');
}
