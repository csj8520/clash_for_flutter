import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:process_run/shell_run.dart';

String clashName = Platform.isWindows
    ? 'clash-windows-amd64.exe'
    : Platform.isMacOS
        ? 'clash-darwin-arm64'
        : '';

File mainFile = File(Platform.resolvedExecutable);
Directory assetsDir = Platform.isWindows
    ? Directory(path.join(mainFile.parent.path, 'data', 'flutter_assets', 'assets'))
    : Platform.isMacOS
        ? Directory(path.join(mainFile.parent.parent.path, 'Frameworks', 'App.framework', 'Resources', 'flutter_assets', 'assets'))
        : Directory('');

File clashFile = File(path.join(assetsDir.path, 'bin', clashName));

Directory configDir = Directory(path.join(userHomePath, '.config', 'clash-pro'));
File configFile = File(path.join(configDir.path, '.config.yaml'));
