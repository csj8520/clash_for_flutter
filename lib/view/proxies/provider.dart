import 'package:clashf_pro/components/index.dart';
import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';

class Provider extends StatefulWidget {
  const Provider({Key? key, required this.provider}) : super(key: key);
  final ProxiesProviders provider;

  @override
  _ProviderState createState() => _ProviderState();
}

class _ProviderState extends State<Provider> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Row(children: [Text(widget.provider.name), Tag(widget.provider.vehicleType).padding(left: 10)]).expanded()
          ],
        ).height(30),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.provider.proxies.map((e) => ProviderProxies(proxie: e)).toList(),
        )
      ],
    ).width(double.infinity).padding(all: 15);
  }
}

class ProviderProxies extends StatelessWidget {
  const ProviderProxies({Key? key, required this.proxie}) : super(key: key);
  final ProxiesProxy proxie;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(proxie.type),
        Text(proxie.name, overflow: TextOverflow.ellipsis),
        Text(proxie.history.isNotEmpty ? '${proxie.history.last.delay}ms' : '-'),
      ],
    ).constrained(width: 90, height: 110).card();
  }
}
