import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:process_run/shell_run.dart';

class ClashName {
  static String get platform {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'darwin';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  static String get arch {
    return const String.fromEnvironment('OS_ARCH', defaultValue: 'amd64');
  }

  static String get ext {
    if (Platform.isWindows) return '.exe';
    return '';
  }

  static String get name {
    return 'clash-$platform-$arch$ext';
  }
}

class Paths {
  static Directory get assets {
    File mainFile = File(Platform.resolvedExecutable);
    String assetsPath = '../data/flutter_assets/assets';
    if (Platform.isMacOS) assetsPath = '../../Frameworks/App.framework/Resources/flutter_assets/assets';
    return Directory(path.normalize(path.join(mainFile.path, assetsPath)));
  }

  static Directory get assetsBin {
    return Directory(path.join(assets.path, 'bin'));
  }

  static Directory get assetsDep {
    return Directory(path.join(assets.path, 'dep'));
  }

  static Directory get config {
    return Directory(path.join(userHomePath, '.config', 'clash-for-flutter'));
  }
}

class Files {
  static File get assetsClashCore {
    return File(path.join(Paths.assetsBin.path, ClashName.name));
  }

  static File get assetsClashService {
    return File(path.join(Paths.assetsBin.path, 'clash-for-flutter-service-${ClashName.platform}-${ClashName.arch}${ClashName.ext}'));
  }

  static File get assetsCountryMmdb {
    return File(path.join(Paths.assetsDep.path, 'Country.mmdb'));
  }

  static File get assetsWintun {
    return File(path.join(Paths.assetsDep.path, 'wintun.dll'));
  }

  static File get assetsExample {
    return File(path.join(Paths.assetsDep.path, 'example.yaml'));
  }

  static File get configConfig {
    return File(path.join(Paths.config.path, '.config.json'));
  }

  static File get configCountryMmdb {
    return File(path.join(Paths.config.path, 'Country.mmdb'));
  }

  static File get configWintun {
    return File(path.join(Paths.config.path, 'wintun.dll'));
  }

  static File get configExample {
    return File(path.join(Paths.config.path, 'example.yaml'));
  }
}
