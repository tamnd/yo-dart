/// Dart client for yo, an embedded multi-model database in one file.
///
/// This library imports nothing from Flutter, so a server side Dart program on
/// shelf, Serverpod or Dart Frog can depend on it without pulling the SDK in.
/// The Flutter lifecycle observer and the path_provider helper live in
/// `package:yodb/flutter.dart`, which arrives with the engine.
library;

export 'src/code.dart' show YoCode;
export 'src/exception.dart'
    show
        YoClosed,
        YoCorrupt,
        YoException,
        YoLocked,
        YoNotFound,
        YoOutOfMemory,
        YoShapeMismatch,
        YoUnknownFailure,
        YoVersionTooNew,
        YoWrongType;
export 'src/version.dart' show Yodb;
