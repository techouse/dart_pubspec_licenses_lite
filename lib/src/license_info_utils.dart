library dart_oss_licenses;

import 'dart:io' show File, Platform;

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' show loadYaml;

import 'package.dart' show Package;

Stream<Package> getPackagesStream(String pubspecLockPath) async* {
  final String? pubCacheDir = _getPubCacheDir();
  if (pubCacheDir == null) throw 'could not find pub cache directory';

  final String pubspecLock = await File(pubspecLockPath).readAsString();
  final pubspec = loadYaml(pubspecLock);

  if (pubspec['packages'] == null) throw 'Invalid packages.lock file!';

  final Map packages = pubspec['packages'] as Map;

  for (final node in packages.keys) {
    final Package? package = await Package.fromMap(
      outerName: node,
      packageJson: packages[node],
      pubCacheDirPath: pubCacheDir,
    );

    if (package != null && package.name != null) {
      yield package;
    }
  }
}

String? _getPubCacheDir() {
  final String? home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

  return home != null ? path.join(home, '.pub-cache') : null;
}
