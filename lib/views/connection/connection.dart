import 'dart:async';

import 'package:get/get.dart';
import 'package:davi/davi.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/types/connect.dart';
import 'package:clash_for_flutter/widgets/card_view.dart';
import 'package:clash_for_flutter/widgets/card_head.dart';
import 'package:clash_for_flutter/controllers/controllers.dart';
import 'package:clash_for_flutter/views/connection/connect_detail.dart';

class PageConnection extends StatefulWidget {
  const PageConnection({Key? key}) : super(key: key);

  @override
  State<PageConnection> createState() => _PageConnectionState();
}

class _PageConnectionState extends State<PageConnection> {
  final TextEditingController _filterTextEditingController = TextEditingController();

  static Color hoverColor(int _) => const Color(0x10111111);
  static Color rowColor(int _) => Colors.white;
  // static const Color headerBgColor = Color(0xfff3f6f9);
  static const Color headerTextColor = Color(0xff909399);
  static const Color dividerColor = Color(0x10555555);

  static Widget sortIconBuilder(DaviSortDirection direction, SortIconColors color) => direction == DaviSortDirection.ascending
      ? Icon(Icons.keyboard_arrow_up, color: color.ascending, size: 18)
      : Icon(Icons.keyboard_arrow_down, color: color.descending, size: 18);

  static const DaviThemeData _daviThemeData = DaviThemeData(
    decoration: BoxDecoration(),
    topCornerBorderColor: Colors.transparent,
    topCornerColor: Colors.transparent,
    bottomCornerBorderColor: Colors.transparent,
    bottomCornerColor: Colors.transparent,
    columnDividerThickness: 1,
    columnDividerColor: Colors.transparent,
    header: HeaderThemeData(
      bottomBorderHeight: 1,
      bottomBorderColor: dividerColor,
      columnDividerColor: dividerColor,
    ),
    row: RowThemeData(
      dividerThickness: 0,
      color: rowColor,
      hoverBackground: hoverColor,
    ),
    cell: CellThemeData(
      textStyle: TextStyle(color: Color(0xff54759a), fontSize: 14),
      alignment: Alignment.center,
    ),
    headerCell: HeaderCellThemeData(
      textStyle: TextStyle(color: headerTextColor, fontSize: 14),
      alignment: Alignment.center,
      sortIconColors: SortIconColors(ascending: headerTextColor, descending: headerTextColor),
      sortIconBuilder: sortIconBuilder,
    ),
    scrollbar: TableScrollbarThemeData(
      thickness: 8,
      radius: Radius.circular(4),
      thumbColor: Color.fromARGB(100, 0, 0, 0),
      verticalColor: Colors.transparent,
      verticalBorderColor: Colors.transparent,
      unpinnedHorizontalColor: Colors.transparent,
      unpinnedHorizontalBorderColor: Colors.transparent,
      pinnedHorizontalBorderColor: Colors.transparent,
      pinnedHorizontalColor: Colors.transparent,
    ),
  );

  late StreamSubscription<RunningState> _coreStatusSub;
  late StreamSubscription<bool> _windowStatusSub;

  @override
  void initState() {
    _handleStateChange();
    _coreStatusSub = controllers.service.coreStatus.stream.listen(_handleStateChange);
    _windowStatusSub = controllers.window.isVisible.stream.listen(_handleStateChange);

    _filterTextEditingController
      ..text = controllers.pageConnection.filter
      ..addListener(() => controllers.pageConnection.filter = _filterTextEditingController.text);

    super.initState();
  }

  void _handleStateChange([dynamic _]) async {
    final coreStatus = controllers.service.coreStatus.value;
    final isVisible = controllers.window.isVisible.value;

    if (coreStatus == RunningState.running && isVisible) {
      await controllers.pageConnection.init();
    } else {
      await controllers.pageConnection.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => [
          CardHead(
            title: 'connection_title'.tr,
            suffix: Row(
              children: [
                Text('connection_total'.trParams({
                  "upload": bytesToSize(controllers.pageConnection.connect.value.uploadTotal),
                  "download": bytesToSize(controllers.pageConnection.connect.value.downloadTotal)
                })).textColor(Theme.of(context).primaryColor).fontSize(14).padding(left: 10, right: 10).expanded(),
                Row(
                  children: [
                    Text("connection_filter".tr).textColor(Colors.grey.shade700).padding(right: 10),
                    TextField(
                      controller: _filterTextEditingController,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'chrome | github & TUN',
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        suffixIcon: IconButton(
                          onPressed: () => _filterTextEditingController.text = '',
                          icon: Icon(Icons.clear, size: 12, color: Colors.grey.shade500),
                          padding: const EdgeInsets.all(0),
                        ),
                        suffixIconConstraints: const BoxConstraints.tightFor(width: 24, height: 20),
                      ),
                    ).decorated(border: Border.all(width: 1, color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)).expanded(),
                  ],
                ).padding(right: 20).expanded(),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.red,
                  iconSize: 20,
                  tooltip: 'Close All Connections',
                  onPressed: controllers.pageConnection.hanldeCloseAllConnections.bindOne(context),
                  constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                  padding: EdgeInsets.zero,
                ),
              ],
            ).padding(right: 10).expanded(),
          ),
          CardView(
            child: Stack(
              children: [
                DaviTheme(
                  data: _daviThemeData,
                  child: Davi<ConnectConnection>(
                    controllers.pageConnection.model,
                    onRowTap: controllers.pageConnection.handleShowDetail,
                  ),
                ),
                if (controllers.pageConnection.detail.value != null)
                  ConnectDetail(
                      connection: controllers.pageConnection.detail.value!,
                      closed: controllers.pageConnection.detailClosed.value,
                      onClose: () => controllers.pageConnection.handleShowDetail(null)),
              ],
            ),
          ).expanded()
        ].toColumn().padding(top: 5, right: 20, bottom: 20));
  }

  @override
  void dispose() {
    _coreStatusSub.cancel();
    _windowStatusSub.cancel();
    controllers.pageConnection.clear();
    _filterTextEditingController.dispose();
    super.dispose();
  }
}
