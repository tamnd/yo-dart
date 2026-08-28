# yo-dart

Dart and Flutter client for [yo](https://github.com/tamnd/yo), an embedded multi-model database that lives in one `.yo` file. Your own types are the schema and there is no query language to learn.

## Status

Early, and honest about it. There is no database in this package yet.

What is here is the error surface from `dx/15` §6 and the version contract: a sealed `YoException` hierarchy carrying all five fields that cross the C ABI, `YoCode` with the code table, and the constants that pin this package to an engine version. Those are the parts that do not need an engine to exist, and everything else is built on top of them.

The typed collection API arrives with the native library, which the release train in `tamnd/yo` builds and vendors per platform once `M1` lands a record plane. Until then `dart test` passes and never opens a file.

The version is `0.0.0` and it means what it says. This package is published so the name is held and the CI is real before either matters.

## Requirements

Dart 3.10 or newer.

That floor is current minus three, which is looser than the Swift binding's current minus one, and the difference is deliberate. Dart ships quarterly, and a Flutter app's SDK constraint is usually set by its oldest transitive dependency rather than by its author. A tight floor here is not a strict package, it is a resolution failure in somebody else's `pubspec.yaml`.

## Install

```
dart pub add yodb
```

or for a Flutter app:

```
flutter pub add yodb
```

## No Flutter dependency

`package:yodb/yodb.dart` imports nothing from Flutter, so a server side Dart program on shelf, Serverpod or Dart Frog can depend on it without pulling the SDK in. The lifecycle observer and the `path_provider` helper live in `package:yodb/flutter.dart`, which arrives with the engine and takes the dependency there.

There are no runtime dependencies at all, and keeping it that way is a decision rather than an accident. Every package this one depends on is a package every app using it also depends on, whether that app wanted it or not.

## Errors

Every failure is a `YoException`, and the hierarchy is `sealed`.

```dart
try {
  final user = db.users.get(1);
} on YoException catch (e) {
  switch (e) {
    case YoShapeMismatch():
      print(e.position);  // users.score
      print(e.detail);    // the field by field diff, multi-line
      print(e.url);       // https://yo.tamnd.dev/errors/shape-mismatch
    case YoNotFound():
      return null;
    default:
      rethrow;
  }
}
```

Because it is sealed, an exhaustive switch is checked by the analyzer and it names the case you forgot. That is the Dart equivalent of the Swift binding's typed throws, and it beats a bare enum because each subtype carries the fields the others have no use for.

`toString()` renders every field and truncates none of them. Flutter's error console truncates at its own layer, and a shape mismatch whose diff got cut off is worse than no diff at all because it looks like the whole answer.

## Publishing

Publishing runs on a tag, over OIDC, using pub.dev automated publishing. There is no publish credential in this repository's secrets and there is not meant to be one: a long lived token works from anywhere, forever, for anyone who reads it once, and the OIDC exchange gives this workflow a credential that lasts minutes.

Before a tag can publish, CI checks that the tag, `pubspec.yaml` and `lib/src/version.dart` all agree and that `CHANGELOG.md` has an entry. A pub.dev version cannot be replaced once published, only retracted, so those checks run on every pull request rather than once at the end.

## Building on this repository

```
dart pub get
dart format .
dart analyze --fatal-infos
dart test
```

CI also runs `pana` with a zero tolerance threshold, so the pub.dev score is known before pub.dev computes it, and `dart pub publish --dry-run` on every pull request.

## Licence

Apache 2.0 or MIT, at your option. See [LICENSE-APACHE](LICENSE-APACHE) and [LICENSE-MIT](LICENSE-MIT).

Unless you say otherwise, a contribution you submit for inclusion here is dual licensed on the same terms, with no additional conditions.

`LICENSE` is a verbatim copy of the Apache 2.0 text rather than a combined file, and that is a tooling constraint rather than a narrowing of the grant. Automated license detection matches a file against known texts, so a combined file with a preamble is detected as no license at all. The option to take MIT instead stands, and `LICENSE-MIT` is the copy of it.
