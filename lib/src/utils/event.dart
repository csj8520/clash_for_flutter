class Event {
  final Map<String, List<Function>> _events = {};

  Event on(String key, Function handle) {
    final handles = _events[key] ??= [];
    if (!handles.contains(handle)) handles.add(handle);
    return this;
  }

  Event emit(String key, dynamic arg) {
    final handles = _events[key];
    handles?.forEach((it) => it(arg));
    return this;
  }

  Event off(String key, Function handle) {
    final handles = _events[key];
    if (handles == null) return this;
    handles.remove(handle);
    if (handles.isEmpty) _events.remove(key);
    return this;
  }
}
