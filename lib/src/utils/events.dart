import 'package:clash_for_flutter/src/utils/index.dart';

class PageVisibleEvent {
  String? _page;
  final Event _event = Event();

  show(String page) {
    if (_page != null) _event.emit(_page!, false);
    _page = page;
    _event.emit(page, true);
  }

  hide() {
    if (_page == null) return;
    _event.emit(_page!, false);
    _page = null;
  }

  onVisible(String page, Function(bool show) callback) {
    if (_page == page) callback(true);
    _event.on(page, callback);
  }
}
