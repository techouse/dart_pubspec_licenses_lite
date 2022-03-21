import 'dart:io' show Directory, File, IOSink, exitCode, stderr, stdout;

import 'package:args/args.dart' show ArgParser, ArgResults;
import 'package:dart_pubspec_licenses_lite/dart_pubspec_licenses_lite.dart'
    show Package, getPackagesStream;
import 'package:path/path.dart' as path;

bool verbose = false;

void main(List<String> arguments) async {
  try {
    exitCode = 0;

    final ArgParser parser = ArgParser()
      ..addOption('pubspec-lock', abbr: 'i', mandatory: true)
      ..addOption('output', abbr: 'o', mandatory: true)
      ..addFlag('verbose', abbr: 'v', defaultsTo: false);
    final ArgResults args = parser.parse(arguments);

    verbose = args['verbose'];

    final String cwd = Directory.current.path;

    final File pubspecLock = File(path.join(cwd, args['pubspec-lock']));
    if (!await pubspecLock.exists()) {
      throw '${pubspecLock.path} does not exist!';
    }
    final Stream<Package> packages = getPackagesStream(pubspecLock.path);

    final File licensesFile = File(path.join(cwd, args['output']));
    if (await licensesFile.exists()) {
      await licensesFile.delete();
      await licensesFile.create();
    }

    final IOSink sink = licensesFile.openWrite();

    packages.listen(
      (Package package) {
        sink.writeln('PACKAGE NAME: ${package.name?.trim()}');
        sink.writeln('PACKAGE VERSION: ${package.version?.trim()}');
        sink.writeln('PACKAGE HOMEPAGE: ${package.homepage?.trim()}');
        sink.writeln('LICENSE:');
        sink.writeln(package.license?.trim());
        sink.writeln('');
        sink.writeln('----------');
        sink.writeln('');
      },
      onDone: () => sink.close(),
    );

    if (verbose) stdout.writeln('Wrote: ${licensesFile.path}');
  } on FormatException catch (err) {
    exitCode = 2;
    stderr.writeln(err.toString());
    if (verbose) rethrow;
  } catch (err) {
    exitCode = 1;
    stderr.writeln(err.toString());
    if (verbose) rethrow;
  }
}
