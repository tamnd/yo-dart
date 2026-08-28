import 'package:test/test.dart';
import 'package:yodb/yodb.dart';

void main() {
  group('YoCode', () {
    test('wire names are screaming snake case and non empty', () {
      for (final code in YoCode.values) {
        expect(code.wireName, isNotEmpty);
        expect(code.wireName, equals(code.wireName.toUpperCase()));
        expect(code.wireName, isNot(contains(' ')));
      }
    });

    test('wire names are unique', () {
      final names = YoCode.values.map((c) => c.wireName).toSet();
      expect(names, hasLength(YoCode.values.length));
    });

    test('integer values are unique and never reused', () {
      final values = YoCode.values.map((c) => c.value).toSet();
      expect(values, hasLength(YoCode.values.length));
    });

    test('slugs are url safe', () {
      final safe = RegExp(r'^[a-z0-9-]+$');
      for (final code in YoCode.values) {
        expect(code.slug, matches(safe));
      }
    });

    test('only the codes that can clear on their own are retryable', () {
      expect(YoCode.timeout.isRetryable, isTrue);
      expect(YoCode.locked.isRetryable, isTrue);
      expect(YoCode.epochStalled.isRetryable, isTrue);
      expect(YoCode.shapeMismatch.isRetryable, isFalse);
      expect(YoCode.corrupt.isRetryable, isFalse);
      expect(YoCode.notFound.isRetryable, isFalse);
    });

    test('fromValue round trips every code', () {
      for (final code in YoCode.values) {
        expect(YoCode.fromValue(code.value), same(code));
      }
    });

    test('fromValue returns null for a code this build predates', () {
      expect(YoCode.fromValue(9999), isNull);
    });
  });

  group('YoException', () {
    test('a url is always present and follows the code', () {
      const e = YoShapeMismatch(message: 'types differ');
      expect(
        e.url.toString(),
        equals('https://yo.tamnd.dev/errors/shape-mismatch'),
      );
    });

    test('retryable follows the code by default', () {
      expect(const YoLocked(message: 'held by 4021').retryable, isTrue);
      expect(const YoCorrupt(message: 'bad page').retryable, isFalse);
    });

    test('an unknown failure carries the code it was handed', () {
      const e = YoUnknownFailure(
        code: YoCode.timeout,
        message: 'slow',
        retryable: false,
      );
      expect(e.code, equals(YoCode.timeout));
      expect(e.retryable, isFalse);
    });

    test('toString carries every field and truncates none of them', () {
      const diff = '- score: double\n+ score: int';
      const e = YoShapeMismatch(
        message: 'the type passed does not match the stored collection',
        position: 'users.score',
        detail: diff,
      );
      final rendered = e.toString();

      expect(rendered, contains('SHAPE_MISMATCH'));
      expect(rendered, contains('users.score'));
      expect(rendered, contains('- score: double'));
      expect(rendered, contains('+ score: int'));
      expect(rendered, contains('https://yo.tamnd.dev/errors/shape-mismatch'));
    });

    test('a missing position or detail leaves no empty section behind', () {
      final rendered = const YoClosed(message: 'handle is closed').toString();
      expect(rendered, isNot(contains('at:')));
      expect(rendered, contains('CLOSED: handle is closed'));
    });

    test('the hierarchy is exhaustive over a switch', () {
      // If a subtype is added without a case here the analyzer fails the build,
      // which is the entire reason YoException is sealed.
      String describe(YoException e) => switch (e) {
        YoNotFound() => 'not found',
        YoWrongType() => 'wrong type',
        YoShapeMismatch() => 'shape mismatch',
        YoLocked() => 'locked',
        YoCorrupt() => 'corrupt',
        YoClosed() => 'closed',
        YoOutOfMemory() => 'out of memory',
        YoVersionTooNew() => 'version too new',
        YoUnknownFailure() => 'unknown',
      };

      expect(describe(const YoNotFound(message: 'x')), equals('not found'));
      expect(describe(const YoCorrupt(message: 'x')), equals('corrupt'));
    });
  });

  group('Yodb', () {
    test('the documentation host has no trailing slash to double up on', () {
      expect(Yodb.documentationHost.toString(), equals('https://yo.tamnd.dev'));
    });

    test('every code has a documentation url under the errors path', () {
      for (final code in YoCode.values) {
        final url = Yodb.documentationUrlFor(code);
        expect(url.toString(), startsWith('https://yo.tamnd.dev/errors/'));
      }
    });

    test('the version is a three part semantic version', () {
      final parts = Yodb.version.split('.');
      expect(parts, hasLength(3));
      for (final part in parts) {
        expect(int.tryParse(part), isNotNull);
      }
    });
  });
}
