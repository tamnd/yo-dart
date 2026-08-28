// pub.dev looks for an example, and a package with none loses points for a
// reason that is not pedantry: the example is the first thing most people read.
//
// There is no database to demonstrate yet, so this shows the part of the API
// that does exist, which is how a failure is reported. Once the engine lands
// this file becomes an open, a put and a get, and the error handling below
// stays exactly as it is.

import 'package:yodb/yodb.dart';

void main() {
  print(
    'yodb ${Yodb.version}, abi ${Yodb.abiVersion}, '
    'format ${Yodb.formatVersion}',
  );

  try {
    throw const YoShapeMismatch(
      message: 'the type passed to docs() does not match the stored collection',
      position: 'users.score',
      detail: '- score: double\n+ score: int',
    );
  } on YoException catch (e) {
    // Sealed, so the analyzer names the case you forgot rather than letting a
    // new error code fall silently into a default branch.
    switch (e) {
      case YoShapeMismatch():
        print('the stored shape and the requested type differ:');
        print(e.detail);
        print('read more at ${e.url}');
      case YoNotFound():
        print('nothing there');
      default:
        print(e);
    }
  }
}
