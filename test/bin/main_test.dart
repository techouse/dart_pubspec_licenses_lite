import 'dart:io' show File;

import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  group('dart-pubspec-licenses-lite', () {
    test('output', () async {
      final TestProcess process = await TestProcess.start(
        'dart',
        ['run', 'bin/main.dart', '-i', 'test/fixtures/example_pubspec.lock'],
      );

      await expectLater(
        process.stdout,
        emitsThrough(
          startsWith('PACKAGE NAME:'),
        ),
      );
      await expectLater(
        process.stdout,
        emitsThrough(
          startsWith('PACKAGE VERSION:'),
        ),
      );
      await expectLater(
        process.stdout,
        emitsThrough(
          startsWith('PACKAGE HOMEPAGE:'),
        ),
      );
      await expectLater(
        process.stdout,
        emitsThrough(
          startsWith('LICENSE:'),
        ),
      );

      // Assert that the process exits with code 0.
      await process.shouldExit(0);
    });

    test('whole output', () async {
      final TestProcess process = await TestProcess.start(
        'dart',
        ['run', 'bin/main.dart', '-i', 'test/fixtures/example_pubspec.lock'],
      );

      final List<String> output = [];
      while (await process.stdout.hasNext) {
        output.add(await process.stdout.next);
      }

      // Assert that the process exits with code 0.
      await process.shouldExit(0);

      expect(
        output.join('\n').trim(),
        equals(
          File('test/fixtures/example_output.txt').readAsStringSync().trim(),
        ),
      );
    });

    test('file output', () async {
      final TestProcess process = await TestProcess.start(
        'dart',
        [
          'run',
          'bin/main.dart',
          '-i',
          'test/fixtures/example_pubspec.lock',
          '-o',
          'test/output.txt'
        ],
      );

      // Assert that the process exits with code 0.
      await process.shouldExit(0);

      expect(File('test/output.txt').existsSync(), true);

      expect(
        File('test/output.txt').readAsStringSync(),
        equals(File('test/fixtures/example_output.txt').readAsStringSync()),
      );

      File('test/output.txt').deleteSync();
      expect(File('test/output.txt').existsSync(), false);
    });
  });
}
