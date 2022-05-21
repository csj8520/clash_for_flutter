import 'package:easy_table/easy_table.dart';
import 'package:get/get.dart';
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

  @override
  void initState() {
    controllers.pageConnection.initDate();
    _filterTextEditingController.text = controllers.pageConnection.filter;
    _filterTextEditingController.addListener(() {
      controllers.pageConnection.filter = _filterTextEditingController.text;
    });

    super.initState();
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
                })).textColor(Theme.of(context).primaryColor).fontSize(14).padding(left: 10, right: 50),
                Row(
                  children: [
                    Text("connection_filter".tr).textColor(Colors.grey.shade700).padding(right: 10),
                    TextField(
                      controller: _filterTextEditingController,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'google | github & TUN',
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ).width(150).decorated(border: Border.all(width: 1, color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                  ],
                ).expanded(),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.red,
                  iconSize: 20,
                  tooltip: 'Close All Connections',
                  onPressed: () => controllers.pageConnection.hanldeCloseAllConnections(context),
                  constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                  padding: EdgeInsets.zero,
                ),
              ],
            ).padding(right: 10).expanded(),
          ),
          CardView(
            child: Stack(
              children: [
                EasyTableTheme(
                  data: const EasyTableThemeData(
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
                      hoveredColor: hoverColor,
                    ),
                    cell: CellThemeData(
                      textStyle: TextStyle(color: Color(0xff54759a)),
                      alignment: Alignment.center,
                    ),
                    headerCell: HeaderCellThemeData(
                      textStyle: TextStyle(color: headerTextColor),
                      alignment: Alignment.center,
                      sortIconColor: headerTextColor,
                      ascendingIcon: Icons.keyboard_arrow_up,
                      descendingIcon: Icons.keyboard_arrow_down,
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
                  ),
                  child: EasyTable<ConnectConnection>(
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
    controllers.pageConnection.clearDate();
    _filterTextEditingController.dispose();
    super.dispose();
  }
}
