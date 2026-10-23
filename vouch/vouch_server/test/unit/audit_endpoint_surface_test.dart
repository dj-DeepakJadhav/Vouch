import 'dart:io';

import 'package:test/test.dart';

// AuditEvent is append-only by design (GDPR Art. 30): no update/delete/remove
// method may ever be exposed on AuditEndpoint.
//
// Dart has no cheap, dependency-free reflection to enumerate a class's
// method names at test time (`dart:mirrors` is unavailable outside the VM's
// non-AOT reflective mode and isn't wired into this project's test setup).
// As a documented fallback, this test asserts directly on the endpoint's
// source text: no method name may start with `update`, `delete`, or
// `remove`. This is a static safeguard, not a runtime one — a rename that
// dodges the substring check would slip through it.
void main() {
  group('Given the AuditEndpoint source file', () {
    late String source;

    setUpAll(() {
      final file = File(
        '${Directory.current.path}/lib/src/audit/audit_endpoint.dart',
      );
      source = file.readAsStringSync();
    });

    test('when scanning for method declarations then none are named '
        'update/delete/remove', () {
      final methodDeclPattern = RegExp(
        r'(\w+)\s*\(\s*\n\s*Session\s+session',
      );
      final forbiddenPrefixes = ['update', 'delete', 'remove'];

      final methodNames = methodDeclPattern
          .allMatches(source)
          .map((m) => m.group(1)!)
          .toList();

      expect(
        methodNames,
        isNotEmpty,
        reason: 'expected to find at least the listRecent method',
      );

      for (final name in methodNames) {
        final lower = name.toLowerCase();
        final forbidden = forbiddenPrefixes.any(
          (prefix) => lower.startsWith(prefix),
        );
        expect(
          forbidden,
          isFalse,
          reason:
              'AuditEndpoint must not expose a method named "$name" — '
              'AuditEvent is append-only.',
        );
      }

      expect(methodNames, contains('listRecent'));
    });

    test('when scanning the whole file then it contains no db.updateRow or '
        'db.deleteRow calls', () {
      expect(source.contains('.updateRow('), isFalse);
      expect(source.contains('.deleteRow('), isFalse);
      expect(source.contains('.deleteWhere('), isFalse);
    });
  });
}
