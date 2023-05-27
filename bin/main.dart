import 'dart:io' show Directory, File, IOSink, exitCode, stderr, stdout;

import 'package:args/args.dart' show ArgParser, ArgResults;
import 'package:dart_pubspec_licenses_lite/dart_pubspec_licenses_lite.dart'
    show Package, getPackagesStream;
import 'package:path/path.dart' as path;

bool verbose = false;

final ArgParser parser = ArgParser()
  ..addOption('pubspec-lock',
      abbr: 'i', help: 'Input pubscpec.lock file', mandatory: true)
  ..addOption(
    'output',
    abbr: 'o',
    help: 'Output combined_licenses.txt',
    defaultsTo: null,
  )
  ..addFlag(
    'verbose',
    abbr: 'v',
    help: 'Show additional diagnostic info',
    defaultsTo: false,
  );

void main(List<String> arguments) async {
  try {
    exitCode = 0;

    final ArgResults args = parser.parse(arguments);

    verbose = args['verbose'];

    final String cwd = Directory.current.path;

    final File pubspecLock = File(path.join(cwd, args['pubspec-lock']));
    if (!await pubspecLock.exists()) {
      throw '${pubspecLock.path} does not exist!';
    }
    final Stream<Package> packages = getPackagesStream(pubspecLock.path);

    if (args['output'] != null) {
      final File licensesFile = File(path.join(cwd, args['output']));
      if (await licensesFile.exists()) {
        await licensesFile.delete();
        await licensesFile.create();
      }

      final IOSink sink = licensesFile.openWrite();

      packages.listen(
        (Package package) {
          sink.writeln(_licenseText(package));
        },
        onDone: () => sink.close(),
      );

      if (verbose) stdout.writeln('Wrote: ${licensesFile.path}');
    } else {
      packages.listen((Package package) {
        stdout.writeln(_licenseText(package));
      });
    }
  } on FormatException catch (err) {
    exitCode = 2;
    stderr.writeln(err.toString());
    stdout.writeln('');
    stdout.writeln(parser.usage);
  } catch (err) {
    exitCode = 1;
    stderr.writeln(err.toString());
    if (verbose) rethrow;
  }
}

String _licenseText(Package package) => <String>[
      'PACKAGE NAME: ${package.name?.trim()}',
      'PACKAGE VERSION: ${package.version?.trim()}',
      'PACKAGE HOMEPAGE: ${package.homepage?.trim()}',
      'LICENSE:',
      package.license?.trim() ?? '',
      '\n----------\n'
    ].join('\n');
