import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/types/config.dart';
import 'package:clash_for_flutter/widgets/edit_profile.dart';

Future<bool?> showNormalDialog(
  BuildContext context, {
  String? content,
  Widget? child,
  required String title,
  required String cancelText,
  required String enterText,
  bool Function()? validator,
}) {
  assert(content != null || child != null);

  return showDialog(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title).textColor(Theme.of(context).primaryColor).textShadow(blurRadius: 6, offset: const Offset(0, 2)),
      content: child ?? Text(content!).textColor(const Color(0xff54759a)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(const Size(62, 32)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            side: MaterialStateProperty.all(const BorderSide(color: Color(0x1a000000), width: 1)),
          ),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => validator?.call() == false ? null : Navigator.pop(c, true),
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(const Size(62, 32)),
            backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            side: MaterialStateProperty.all(const BorderSide(color: Color(0x1a000000), width: 1)),
          ),
          child: Text(enterText).textColor(Colors.white),
        ).boxShadow(color: const Color(0x802c8af8), blurRadius: 8, offset: const Offset(0, 2)),
      ],
    ),
  );
}

Future<ConfigSub?> showEditProfileDialog(BuildContext context,
    {ConfigSub? sub, required String title, bool Function(ConfigSub sub)? validator}) async {
  final child = EditProfile(name: sub?.name, url: sub?.url);
  final res = await showNormalDialog(
    context,
    title: title,
    child: child,
    enterText: '确 定',
    cancelText: '取 消',
    validator: () => validator?.call(ConfigSub(name: child.nameInputController.text, url: child.urlInputController.text)) ?? true,
  );
  if (res != true) return null;
  return ConfigSub(name: child.nameInputController.text, url: child.urlInputController.text, updateTime: sub?.updateTime);
}
