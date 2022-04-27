import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;

import 'package:day/day.dart';
import 'package:day/i18n/zh_cn.dart';
import 'package:day/plugins/relative_time.dart';

import 'package:clash_for_flutter/types/table.dart';
import 'package:clash_for_flutter/utils/utils.dart';
import 'package:clash_for_flutter/types/connect.dart';

final List<TableItem<ConnectConnection>> tableItems = [
  TableItem(
    head: '域名',
    width: 260,
    align: Alignment.centerLeft,
    getLabel: (c) => '${c.metadata.host.isNotEmpty ? c.metadata.host : c.metadata.destinationIP}:${c.metadata.destinationPort}',
  ),
  TableItem(head: '网络', width: 80, align: Alignment.center, getLabel: (c) => c.metadata.network),
  TableItem(head: '类型', width: 120, align: Alignment.center, getLabel: (c) => c.metadata.type),
  TableItem(head: '节点链', width: 200, align: Alignment.centerLeft, tooltip: true, getLabel: (c) => c.chains.reversed.join('/')),
  TableItem(head: '规则', width: 140, align: Alignment.center, getLabel: (c) => '${c.rule}(${c.rulePayload})'),
  TableItem(head: '进程', width: 100, align: Alignment.center, getLabel: (c) => path.basename(c.metadata.processPath)),
  TableItem(
    head: '速率',
    width: 200,
    align: Alignment.center,
    getLabel: (c) {
      final download = c.speed.download;
      final upload = c.speed.upload;
      if (upload == 0 && download == 0) return '-';
      if (upload == 0) return '↓ ${bytesToSize(download)}/s';
      if (download == 0) return '↑ ${bytesToSize(upload)}/s';
      return '↑ ${bytesToSize(upload)}/s ↓ ${bytesToSize(download)}/s';
    },
    sort: (a, b) => (a.speed.download + a.speed.upload) - (b.speed.download + b.speed.upload),
  ),
  TableItem(
    head: '上传',
    width: 100,
    align: Alignment.center,
    getLabel: (c) => bytesToSize(c.upload),
    sort: (a, b) => a.upload - b.upload,
  ),
  TableItem(
    head: '下载',
    width: 100,
    align: Alignment.center,
    getLabel: (c) => bytesToSize(c.download),
    sort: (a, b) => a.download - b.download,
  ),
  TableItem(head: '来源IP', width: 140, align: Alignment.center, getLabel: (c) => c.metadata.sourceIP),
  TableItem(
    head: '连接时间',
    width: 120,
    align: Alignment.center,
    getLabel: (c) => Day().useLocale(locale).from(Day.fromString(c.start)),
    sort: (a, b) => a.start.compareTo(b.start),
  ),
];
