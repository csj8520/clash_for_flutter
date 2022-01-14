// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_config.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$LocalConfigStore on _LocalConfigStore, Store {
  final _$_configAtom = Atom(name: '_LocalConfigStore._config');

  @override
  Map<String, dynamic> get _config {
    _$_configAtom.reportRead();
    return super._config;
  }

  @override
  set _config(Map<String, dynamic> value) {
    _$_configAtom.reportWrite(value, super._config, () {
      super._config = value;
    });
  }

  final _$readLocalConfigAsyncAction =
      AsyncAction('_LocalConfigStore.readLocalConfig');

  @override
  Future<void> readLocalConfig() {
    return _$readLocalConfigAsyncAction.run(() => super.readLocalConfig());
  }

  final _$saveLocalConfigAsyncAction =
      AsyncAction('_LocalConfigStore.saveLocalConfig');

  @override
  Future<void> saveLocalConfig() {
    return _$saveLocalConfigAsyncAction.run(() => super.saveLocalConfig());
  }

  final _$setAutoSetProxyAsyncAction =
      AsyncAction('_LocalConfigStore.setAutoSetProxy');

  @override
  Future<void> setAutoSetProxy(bool value) {
    return _$setAutoSetProxyAsyncAction.run(() => super.setAutoSetProxy(value));
  }

  final _$_LocalConfigStoreActionController =
      ActionController(name: '_LocalConfigStore');

  @override
  void setStartAtLogin(bool value) {
    final _$actionInfo = _$_LocalConfigStoreActionController.startAction(
        name: '_LocalConfigStore.setStartAtLogin');
    try {
      return super.setStartAtLogin(value);
    } finally {
      _$_LocalConfigStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
