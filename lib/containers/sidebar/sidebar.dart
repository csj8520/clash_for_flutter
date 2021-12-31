import 'package:clashf_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class SideBarMenu {
  String label;
  String type;
  SideBarMenu(this.label, this.type);
}

class SideBar extends StatefulWidget {
  const SideBar({Key? key, this.selected = 'agent', this.onChange}) : super(key: key);
  final String selected;
  final Function(SideBarMenu menu)? onChange;

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final _menus = [
    SideBarMenu('代理', 'agent'),
    SideBarMenu('日志', 'log'),
    SideBarMenu('规则', 'rule'),
    SideBarMenu('连接', 'connect'),
    SideBarMenu('设置', 'setting'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/logo.png', width: 60, height: 60),
        ListView.builder(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          itemBuilder: (context, idx) => SlideBarButton(
            label: _menus[idx].label,
            selected: _menus[idx].type == widget.selected,
            onPressed: () => widget.onChange != null ? widget.onChange!(_menus[idx]) : null,
          ),
          itemCount: _menus.length,
        ).expanded(),
      ],
    ).padding(top: 50).width(160);
  }
}

class SlideBarButton extends StatefulWidget {
  const SlideBarButton({Key? key, required this.label, this.onPressed, this.selected = false}) : super(key: key);
  final String label;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  _SlideBarButtonState createState() => _SlideBarButtonState();
}

class _SlideBarButtonState extends State<SlideBarButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        gradient: widget.selected ? const LinearGradient(colors: [Color(0xFF57befc), Color(0xFF2c8af8)], begin: Alignment.topLeft) : null,
      ),
      child: TextButton(
        onPressed: widget.onPressed,
        child: Text(
          widget.label,
          style: TextStyle(color: Color(widget.selected ? 0xffffffff : 0xff909399)),
        ),
        // style: ButtonStyle(
        // overlayColor: MaterialStateProperty.all(const Color(0x2857befc)),
        // shape: MaterialStateProperty.all(
        //   const RoundedRectangleBorder(
        //     // borderRadius: BorderRadius.all(Radius.circular(18)),
        //     side: BorderSide.none,
        //   ),
        // ),
        // ),
      ),
    ).clipRRect(all: 18).padding(top: 10, bottom: 10);
  }
}
