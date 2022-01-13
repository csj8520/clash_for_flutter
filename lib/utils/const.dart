import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:process_run/shell_run.dart';

class CONST {
  static final String _clashBinName = Platform.isWindows ? 'clash-windows-amd64.exe' : 'clash-darwin-arm64';
  static final String _assetsPath =
      Platform.isWindows ? '../data/flutter_assets/assets' : '../../Frameworks/App.framework/Resources/flutter_assets/assets';

  static File mainFile = File(Platform.resolvedExecutable);

  static Directory assetsDir = Directory(path.normalize(path.join(mainFile.path, _assetsPath)));
  static Directory configDir = Directory(path.join(userHomePath, '.config', 'clash-pro'));

  static File configFile = File(path.join(configDir.path, '.config.yaml'));
  static File clashBinFile = File(path.join(assetsDir.path, 'bin', _clashBinName));
}
