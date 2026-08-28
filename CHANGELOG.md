# Changelog

Every tier 1 and tier 2 SDK shares one version number with the engine, so a version that appears here appears in every other binding on the same day.

Pre 1.0 a minor release may break the API. When it does, the entry says so on its first line rather than in a note further down.

## 0.0.1

Still a name reservation. This release exists so that one version number means one artifact across every ecosystem on the same day, which it stopped meaning when the Node placeholder had to be republished to correct the sentence it was serving.

- `Yodb.version` is `0.0.1`.
- No API change, no behaviour change. There is still no database.

## 0.0.0

The name reservation release. It holds `yodb` on pub.dev as a resolvable package and nothing more.

- `YoCode`, the error code table from `dx/02` §2, with the stable integer that crosses FFI and the wire spelling used by the CLI and the docs URLs.
- `YoException`, sealed, with the nine subtypes and all five fields that cross the C ABI: code, message, position, url and the multi-line detail that carries the shape diff.
- `Yodb.version`, `Yodb.abiVersion` and `Yodb.formatVersion`, which pin this package to an engine build.
- CI on the 3.10 floor and on stable, `pana` at a zero tolerance threshold, and a publish dry run on every pull request.
- Publishing over OIDC, with no long lived credential in repository secrets.

There is no database. `dart test` passes without opening a file, which is the point of a reservation release.
