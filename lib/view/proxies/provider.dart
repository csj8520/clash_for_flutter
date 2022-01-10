import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'package:day/day.dart';
import 'package:day/i18n/zh_cn.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clashf_pro/components/index.dart';
import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Provider extends StatefulWidget {
  const Provider({Key? key, required this.provider, required this.onUpdate}) : super(key: key);
  final ProxiesProviders provider;
  final FutureFunc onUpdate;

  @override
  _ProviderState createState() => _ProviderState();
}

class _ProviderState extends State<Provider> {
  double _height = 100;

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        useDefaultLoading: false,
        overlayWidget: Center(
          child: SpinKitPulse(color: Theme.of(context).primaryColor, size: 50.0),
        ).height(_height).backgroundColor(const Color(0x66000000)),
        child: Column(
          children: [
            Row(
              children: [
                Row(children: [Text(widget.provider.name), Tag(widget.provider.vehicleType).padding(left: 10)]).expanded(),
                Text(Day().useLocale(locale).from(Day.fromString(widget.provider.updatedAt))),
                IconButton(
                  icon: Icon(Icons.network_check, size: 20, color: Theme.of(context).primaryColor),
                  onPressed: () async {
                    setState(() => _height = context.size?.height ?? 100);
                    context.loaderOverlay.show();
                    try {
                      await fetchClashProviderProxiesHealthCheck(widget.provider.name);
                      await widget.onUpdate();
                    } catch (e) {
                      BotToast.showText(text: 'Updata Error');
                    }
                    context.loaderOverlay.hide();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.refresh, size: 20, color: Theme.of(context).primaryColor),
                  onPressed: () async {
                    setState(() => _height = context.size?.height ?? 100);
                    context.loaderOverlay.show();
                    try {
                      await fetchClashProviderProxiesUpdate(widget.provider.name);
                      await widget.onUpdate();
                    } catch (e) {
                      BotToast.showText(text: 'Updata Error');
                    }
                    context.loaderOverlay.hide();
                  },
                )
              ],
            ).height(40),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.provider.proxies.map((e) => ProviderProxies(proxie: e)).toList(),
            ).padding(top: 20)
          ],
        ).width(double.infinity).padding(all: 15));
  }
}

class ProviderProxies extends StatefulWidget {
  const ProviderProxies({Key? key, required this.proxie, this.clickable = false}) : super(key: key);
  final ProxiesProxy proxie;
  final bool clickable;

  @override
  _ProviderProxiesState createState() => _ProviderProxiesState();
}

class _ProviderProxiesState extends State<ProviderProxies> {
  final colors = {
    const Color(0xff909399): 0,
    const Color(0xff00c520): 260,
    const Color(0xffff9a28): 600,
    const Color(0xffff3e5e): double.infinity,
  };

  @override
  Widget build(BuildContext context) {
    final proxie = widget.proxie;
    final delay = proxie.delay;
    final name = proxie.name;
    Color color = colors.keys.firstWhere((it) => (delay <= colors[it]!));

    return TextButton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(proxie.type)
              .textColor(Colors.white)
              .fontSize(10)
              .padding(left: 5, right: 5, top: 2, bottom: 2)
              .backgroundColor(color)
              .clipRRect(all: 2),
          Text(name, overflow: TextOverflow.ellipsis, maxLines: 2).textColor(const Color(0xff54759a)).fontSize(10),
          Text(delay == 0 ? '-' : '${delay}ms').textColor(const Color(0xcc54759a)).fontSize(10),
        ],
      ).padding(left: 10, right: 10, top: 15, bottom: 15),
      onPressed: widget.clickable
          ? () async {
              proxie.delay = await fetchProxyDelay(name);
              setState(() {});
            }
          : null,
    ).constrained(width: 90, height: 100).decorated(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
      boxShadow: [const BoxShadow(color: Color(0x332c8af8), blurRadius: 24)],
    );
  }
}
