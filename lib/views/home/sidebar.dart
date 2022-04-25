import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/store/clash_core.dart';

class SideBarMenu {
  String label;
  String type;
  SideBarMenu(this.label, this.type);
}

class SideBar extends StatefulWidget {
  const SideBar({Key? key, required this.menus, required this.controller}) : super(key: key);
  final List<String> menus;
  final PageController controller;

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final StoreClashCore storeClashCore = Get.find();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/logo/logo_64.png', width: 64, height: 64, filterQuality: FilterQuality.medium),
        ListView.builder(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
          itemBuilder: (context, idx) => _SlideBarButton(
            label: widget.menus[idx],
            value: idx == widget.controller.page,
            onPressed: () => widget.controller.jumpToPage(idx),
          ),
          itemCount: widget.menus.length,
        ).expanded(),
        TextButton(
          child: Obx(() => Column(
                children: [
                  Text('clash_core_version'.tr)
                      .textColor(Theme.of(context).primaryColor)
                      .textShadow(color: const Color(0x662c8af8), blurRadius: 6, offset: const Offset(0, 2))
                      .fontSize(14),
                  Text(storeClashCore.version.value.version).textColor(const Color(0xff54759a)).fontSize(14).padding(top: 8, bottom: 8),
                  const Text('Premium')
                      .textColor(Theme.of(context).primaryColor)
                      .textShadow(color: const Color(0x662c8af8), blurRadius: 6, offset: const Offset(0, 2))
                      .fontSize(storeClashCore.version.value.premium ? 14 : 0),
                ],
              )),
          onPressed: () => launchUrl(Uri.parse('https://github.com/Dreamacro/clash/releases/tag/premium')),
        )
      ],
    ).padding(top: 50, bottom: 20).width(160);
  }
}

class _SlideBarButton extends StatefulWidget {
  const _SlideBarButton({Key? key, required this.label, this.onPressed, this.value = false}) : super(key: key);
  final String label;
  final VoidCallback? onPressed;
  final bool value;

  @override
  _SlideBarButtonState createState() => _SlideBarButtonState();
}

class _SlideBarButtonState extends State<_SlideBarButton> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this)..addListener(() => setState(() {}));
    if (widget.value) _animationController.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant _SlideBarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.value && widget.value) {
      _animationController.forward(from: 0);
    } else if (oldWidget.value && !widget.value) {
      _animationController.reverse(from: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        gradient: const LinearGradient(colors: [Color(0xff57befc), Color(0xff2c8af8)], begin: Alignment.topLeft).scale(_animationController.value),
      ),
      child: TextButton(
        onPressed: widget.onPressed,
        child: Text(
          widget.label,
          style: TextStyle(color: Color(widget.value ? 0xffffffff : 0xff909399)),
        ),
      ),
    ).clipRRect(all: 18).padding(top: 5, bottom: 5);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
