import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:process_run/shell_run.dart';

class CONST {
  static final String os = Platform.isWindows
      ? "windows"
      : Platform.isMacOS
          ? "darwin"
          : "linux";
  static const String arch = "amd64";
  static final String binExt = Platform.isWindows ? '.exe' : '';
  static final String clashBinName = 'clash-$os-$arch$binExt';
  static final String clashServiceBinName = 'clash-for-flutter-service-$os-$arch$binExt';

  static final String _assetsPath =
      Platform.isWindows ? '../data/flutter_assets/assets' : '../../Frameworks/App.framework/Resources/flutter_assets/assets';

  static File mainFile = File(Platform.resolvedExecutable);

  static Directory assetsDir = Directory(path.normalize(path.join(mainFile.path, _assetsPath)));
  static Directory configDir = Directory(path.join(userHomePath, '.config', 'clash-pro'));

  static File configFile = File(path.join(configDir.path, '.config.json'));
  static File clashBinFile = File(path.join(assetsDir.path, 'bin', clashBinName));
  static File clashServiceBinFile = File(path.join(assetsDir.path, 'bin', clashServiceBinName));
}
