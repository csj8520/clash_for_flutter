import 'clash_api_config.dart';
import 'local_config.dart';
import 'global.dart';
import 'proxies.dart';
import 'connections.dart';

final clashApiConfigStore = ClashApiConfigStore();

final localConfigStore = LocalConfigStore();

final globalStore = GlobalStore();

final proxiesStore = ProxiesStore();

final connectionsStore = ConnectionsStore();
