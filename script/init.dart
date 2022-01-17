import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';

final dio = Dio();

final String clashCoreFileName = Platform.isWindows
    ? 'clash-windows-amd64'
    : Platform.isMacOS
        ? 'clash-darwin-amd64'
        : 'clash-linux-amd64';

// https://github.com/dart-lang/sdk/issues/31610
final assetsPath = path.normalize(path.join(Platform.script.toFilePath(), '../../assets'));
final binDir = Directory(path.join(assetsPath, 'bin'));
final geoipDir = Directory(path.join(assetsPath, 'geoip'));

void main() async {
  if (!(await binDir.exists())) await binDir.create();
  if (!(await geoipDir.exists())) await geoipDir.create();
  final latestInfo = await dio.get('https://api.github.com/repos/Dreamacro/clash/releases/tags/premium');
  final Map<String, dynamic> latest =
      (latestInfo.data['assets'] as List<dynamic>).firstWhere((it) => (it['name'] as String).contains(clashCoreFileName));

  final String name = latest['name'];
  final tempFile = File(path.join(binDir.path, '$name.temp'));

  print('Start Download $name');
  await dio.download(latest['browser_download_url'], tempFile.path);
  print('Download Success');

  print('Start Archive $name');
  final tempBetys = await tempFile.readAsBytes();
  if (name.contains('.gz')) {
    final bytes = GZipDecoder().decodeBytes(tempBetys);
    final String filePath = path.join(binDir.path, clashCoreFileName);
    await File(filePath).writeAsBytes(bytes);
    await Process.run('chmod', ['+x', filePath]);
  } else {
    final file = ZipDecoder().decodeBytes(tempBetys).first;
    await File(path.join(binDir.path, file.name)).writeAsBytes(file.content);
  }
  await tempFile.delete();
  print('Archive Success');

  print('Start Download Geoip');
  final String geoipFilePath = path.join(geoipDir.path, 'Country.mmdb');
  await dio.download('https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb', geoipFilePath);
  print('Download Success');
}
