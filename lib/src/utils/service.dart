import 'index.dart';

Future installService() async {
  await processRunAdmin(CONST.clashServiceBinFile.path, ["install", "start"]);
}

Future unInstallService() async {
  await processRunAdmin(CONST.clashServiceBinFile.path, ["stop", "uninstall"]);
}
