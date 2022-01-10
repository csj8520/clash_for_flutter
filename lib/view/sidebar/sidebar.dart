import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewSideBar extends StatefulWidget {
  const ViewSideBar({Key? key, required this.menus, this.index = 0, this.onChange, this.clashVersion}) : super(key: key);
  final List<SideBarMenu> menus;
  final int index;
  final ClashVersion? clashVersion;
  final Function(SideBarMenu menu, int index)? onChange;

  @override
  _ViewSideBarState createState() => _ViewSideBarState();
}

class _ViewSideBarState extends State<ViewSideBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/logo.png', width: 60, height: 60, filterQuality: FilterQuality.medium),
        ListView.builder(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          itemBuilder: (context, idx) => _SlideBarButton(
            label: widget.menus[idx].label,
            selected: idx == widget.index,
            onPressed: () => widget.onChange != null ? widget.onChange!(widget.menus[idx], idx) : null,
          ),
          itemCount: widget.menus.length,
        ).expanded(),
        TextButton(
          child: Column(
            children: [
              const Text('Clash 版本')
                  .textColor(Theme.of(context).primaryColor)
                  .textShadow(color: const Color(0x662c8af8), blurRadius: 6, offset: const Offset(0, 2))
                  .fontSize(14),
              Text(widget.clashVersion?.version ?? '').textColor(const Color(0xff54759a)).fontSize(14).padding(top: 8, bottom: 8),
              const Text('Premium')
                  .textColor(Theme.of(context).primaryColor)
                  .textShadow(color: const Color(0x662c8af8), blurRadius: 6, offset: const Offset(0, 2))
                  .fontSize(widget.clashVersion?.premium ?? false ? 14 : 0),
            ],
          ),
          onPressed: () => launch('https://github.com/Dreamacro/clash/releases/tag/premium'),
        )
      ],
    ).padding(top: 50, bottom: 20).width(160);
  }
}

class _SlideBarButton extends StatefulWidget {
  const _SlideBarButton({Key? key, required this.label, this.onPressed, this.selected = false}) : super(key: key);
  final String label;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  _SlideBarButtonState createState() => _SlideBarButtonState();
}

class _SlideBarButtonState extends State<_SlideBarButton> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 100),
        vsync: this,
        lowerBound: 0x00,
        upperBound: 0xff)
      ..addListener(() => setState(() {}));
    if (widget.selected) _animationController.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant _SlideBarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.selected && widget.selected) {
      _animationController.forward(from: 0x00);
    } else if (oldWidget.selected && !widget.selected) {
      _animationController.reverse(from: 0xff);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        gradient: LinearGradient(colors: [
          const Color(0x0057befc).withAlpha(_animationController.value.toInt()),
          const Color(0x002c8af8).withAlpha(_animationController.value.toInt())
        ], begin: Alignment.topLeft),
      ),
      child: TextButton(
        onPressed: widget.onPressed,
        child: Text(
          widget.label,
          style: TextStyle(color: Color(widget.selected ? 0xffffffff : 0xff909399)),
        ),
      ),
    ).clipRRect(all: 18).padding(top: 10, bottom: 10);
  }
}
