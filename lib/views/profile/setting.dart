import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';

class PageProfileSetting extends StatefulWidget {
  const PageProfileSetting({Key? key}) : super(key: key);

  @override
  State<PageProfileSetting> createState() => _PageProfileSettingState();
}

class _PageProfileSettingState extends State<PageProfileSetting> {
  final TextEditingController _updateIntervalInputController = TextEditingController();
  final FocusNode _updateIntervalInputfocusNode = FocusNode();

  @override
  void initState() {
    _updateIntervalInputController.text = (controllers.config.config.value.updateInterval / 60 / 60).toString();
    _updateIntervalInputfocusNode.addListener(_updateIntervalInputEvent);
    super.initState();
  }

  Future<void> _updateIntervalInputEvent() async {
    if (!_updateIntervalInputfocusNode.hasFocus) {
      try {
        final time = (double.parse(_updateIntervalInputController.text) * 60 * 60).toInt();
        if (time == controllers.config.config.value.updateInterval) return;
        if (time < 60) {
          BotToast.showText(text: 'profile_update_interval_min'.tr);
          return;
        }
        await controllers.config.setUpdateInterval(time);
      } catch (e) {
        BotToast.showText(text: 'profile_update_interval_error'.tr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardView(
      child: Column(
        children: [
          Row(
            children: [
              Row(
                children: [
                  Text('profile_update_interval'.tr).expanded(),
                  TextField(
                    controller: _updateIntervalInputController,
                    focusNode: _updateIntervalInputfocusNode,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'profile_hour'.tr,
                      labelStyle: const TextStyle(fontSize: 12),
                      floatingLabelStyle: const TextStyle(fontSize: 10),
                      contentPadding: const EdgeInsets.fromLTRB(5, 3, 5, 18),
                      border: InputBorder.none,
                    ),
                  )
                      .constrained(width: 90, height: 30)
                      .decorated(border: Border.all(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                ],
              ).padding(left: 15, right: 15).expanded(),
              const Row().padding(left: 15, right: 15).expanded(),
            ],
          ).padding(top: 10, bottom: 10),
        ],
      ).padding(top: 10, bottom: 10),
    );
  }
}
