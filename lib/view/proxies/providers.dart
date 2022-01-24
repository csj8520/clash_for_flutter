import 'package:clash_pro_for_flutter/store/index.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:day/day.dart';
import 'package:day/i18n/zh_cn.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clash_pro_for_flutter/components/index.dart';
import 'package:clash_pro_for_flutter/fetch/index.dart';
import 'package:clash_pro_for_flutter/types/index.dart';

import 'components/proxie.dart';

class PageProxiesProviders extends StatelessWidget {
  const PageProxiesProviders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return Column(
        children: [
          const CardHead(title: '代理集'),
          ...proxiesStore.providers.map((e) => _Provider(provider: e)),
        ],
      );
    });
  }
}

class _Provider extends StatefulWidget {
  const _Provider({Key? key, required this.provider}) : super(key: key);
  final ProxiesProviders provider;

  @override
  _ProviderState createState() => _ProviderState();
}

class _ProviderState extends State<_Provider> {
  final LoadingController _loadingController = LoadingController();

  _healthCheck() async {
    _loadingController.show();
    try {
      await fetchClashProviderProxiesHealthCheck(widget.provider.name);
      await proxiesStore.update();
    } catch (e) {
      BotToast.showText(text: 'Health Check Error');
    }
    _loadingController.hide();
  }

  _updateProvider() async {
    _loadingController.show();
    try {
      await fetchClashProviderProxiesUpdate(widget.provider.name);
      await proxiesStore.update();
    } catch (e) {
      BotToast.showText(text: 'Updata Error');
    }
    _loadingController.hide();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    return Loading(
      controller: _loadingController,
      child: CardView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(children: [Text(provider.name), Tag(provider.vehicleType).padding(left: 10)]).expanded(),
                Text(provider.updatedAt == null ? '' : '最后更新于：${Day().useLocale(locale).from(Day.fromString(provider.updatedAt!))}'),
                IconButton(icon: Icon(Icons.network_check, size: 20, color: Theme.of(context).primaryColor), onPressed: _healthCheck),
                IconButton(icon: Icon(Icons.refresh, size: 20, color: Theme.of(context).primaryColor), onPressed: _updateProvider)
              ],
            ).height(40),
            Wrap(spacing: 10, runSpacing: 10, children: provider.proxies.map((e) => BlockProxie(proxie: e)).toList()).padding(top: 20)
          ],
        ).width(double.infinity).padding(all: 15),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
