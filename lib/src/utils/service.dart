import 'index.dart';

Future installService() async {
  await runAsAdmin(CONST.clashServiceBinFile.path, ["install", "start"]);
}

Future unInstallService() async {
  try {
    await runAsAdmin(CONST.clashServiceBinFile.path, ["stop", "uninstall"]);
  } catch (e) {
    log.error(e);
  }
}
