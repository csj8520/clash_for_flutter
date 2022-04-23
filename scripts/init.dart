// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:clash_for_flutter/const/const.dart';

final dio = Dio();

// https://github.com/dart-lang/sdk/issues/31610
final assetsPath = path.normalize(path.join(Platform.script.toFilePath(), '../../assets'));
final binDir = Directory(path.join(assetsPath, 'bin'));
final depDir = Directory(path.join(assetsPath, 'dep'));

Future downloadLatestClashCore() async {
  final String clashCoreName = 'clash-${ClashName.platform}-${ClashName.arch}';

  final info = await dio.get('https://api.github.com/repos/Dreamacro/clash/releases/tags/premium');
  final Map<String, dynamic> latest = (info.data['assets'] as List<dynamic>).firstWhere((it) => (it['name'] as String).contains(clashCoreName));

  final String name = latest['name'];
  final tempFile = File(path.join(binDir.path, '$name.temp'));

  print('Downloading $name');
  await dio.download(latest['browser_download_url'], tempFile.path);
  print('Download Success');

  print('Unarchiving $name');
  final tempBetys = await tempFile.readAsBytes();
  if (name.contains('.gz')) {
    final bytes = GZipDecoder().decodeBytes(tempBetys);
    final String filePath = path.join(binDir.path, clashCoreName);
    await File(filePath).writeAsBytes(bytes);
    await Process.run('chmod', ['+x', filePath]);
  } else {
    final file = ZipDecoder().decodeBytes(tempBetys).first;
    await File(path.join(binDir.path, file.name)).writeAsBytes(file.content);
  }
  await tempFile.delete();
  print('Unarchiv Success');
}

Future downloadLatestClashService() async {
  final String serviceName = 'clash-for-flutter-service-${ClashName.platform}-${ClashName.arch}';
  final info = await dio.get('https://api.github.com/repos/csj8520/clash-for-flutter-service/releases/latest');
  final Map<String, dynamic> latest = (info.data['assets'] as List<dynamic>).firstWhere((it) => (it['name'] as String).contains(serviceName));

  final String name = latest['name'];
  final tempFile = File(path.join(binDir.path, '$name.temp'));

  print('Downloading $name');
  await dio.download(latest['browser_download_url'], tempFile.path);
  print('Download Success');

  print('Unarchiving $name');
  final tempBetys = await tempFile.readAsBytes();
  if (name.contains('.gz')) {
    final bytes = GZipDecoder().decodeBytes(tempBetys);
    final String filePath = path.join(binDir.path, serviceName);
    await File(filePath).writeAsBytes(bytes);
    await Process.run('chmod', ['+x', filePath]);
  } else {
    final file = ZipDecoder().decodeBytes(tempBetys).first;
    await File(path.join(binDir.path, file.name)).writeAsBytes(file.content);
  }
  await tempFile.delete();
  print('Unarchiv Success');
}

Future downloadCountryMmdb() async {
  print('Downloading Country.mmdb');
  final String geoipFilePath = path.join(depDir.path, 'Country.mmdb');
  await dio.download('https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb', geoipFilePath);
  print('Download Success');
}

Future downloadWintun() async {
  print('Downloading Wintun');
  final File wintunFile = File(path.join(depDir.path, 'wintun.zip.temp'));
  await dio.download('https://www.wintun.net/builds/wintun-0.14.1.zip', wintunFile.path);
  print('Download Success');
  print('Unarchiving wintun.zip');
  final files = ZipDecoder().decodeBytes(await wintunFile.readAsBytes());
  final file = files.firstWhere((it) => it.name == 'wintun/bin/${ClashName.arch}/wintun.dll');
  await File(path.join(depDir.path, 'wintun.dll')).writeAsBytes(file.content);
  await wintunFile.delete();
  print('Unarchiv Success');
}

void main() async {
  if (!(await binDir.exists())) await binDir.create();
  if (!(await depDir.exists())) await depDir.create();

  await downloadLatestClashCore();
  await downloadLatestClashService();

  await downloadCountryMmdb();
  if (Platform.isWindows) await downloadWintun();
}
