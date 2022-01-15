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

  final _$clashApiAddressAtom = Atom(name: '_LocalConfigStore.clashApiAddress');

  @override
  String get clashApiAddress {
    _$clashApiAddressAtom.reportRead();
    return super.clashApiAddress;
  }

  @override
  set clashApiAddress(String value) {
    _$clashApiAddressAtom.reportWrite(value, super.clashApiAddress, () {
      super.clashApiAddress = value;
    });
  }

  final _$clashApiSecretAtom = Atom(name: '_LocalConfigStore.clashApiSecret');

  @override
  String get clashApiSecret {
    _$clashApiSecretAtom.reportRead();
    return super.clashApiSecret;
  }

  @override
  set clashApiSecret(String value) {
    _$clashApiSecretAtom.reportWrite(value, super.clashApiSecret, () {
      super.clashApiSecret = value;
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

  final _$setStartAtLoginAsyncAction =
      AsyncAction('_LocalConfigStore.setStartAtLogin');

  @override
  Future<void> setStartAtLogin(bool value) {
    return _$setStartAtLoginAsyncAction.run(() => super.setStartAtLogin(value));
  }

  final _$setAutoSetProxyAsyncAction =
      AsyncAction('_LocalConfigStore.setAutoSetProxy');

  @override
  Future<void> setAutoSetProxy(bool value) {
    return _$setAutoSetProxyAsyncAction.run(() => super.setAutoSetProxy(value));
  }

  final _$setSelectedAsyncAction = AsyncAction('_LocalConfigStore.setSelected');

  @override
  Future<void> setSelected(String value) {
    return _$setSelectedAsyncAction.run(() => super.setSelected(value));
  }

  final _$setUpdateIntervalAsyncAction =
      AsyncAction('_LocalConfigStore.setUpdateInterval');

  @override
  Future<void> setUpdateInterval(int value) {
    return _$setUpdateIntervalAsyncAction
        .run(() => super.setUpdateInterval(value));
  }

  final _$setUpdateSubsAtStartAsyncAction =
      AsyncAction('_LocalConfigStore.setUpdateSubsAtStart');

  @override
  Future<void> setUpdateSubsAtStart(bool value) {
    return _$setUpdateSubsAtStartAsyncAction
        .run(() => super.setUpdateSubsAtStart(value));
  }

  final _$setSubAsyncAction = AsyncAction('_LocalConfigStore.setSub');

  @override
  Future<void> setSub(String subName, Map<String, dynamic> value) {
    return _$setSubAsyncAction.run(() => super.setSub(subName, value));
  }

  final _$updateSubAsyncAction = AsyncAction('_LocalConfigStore.updateSub');

  @override
  Future<void> updateSub(Map<String, dynamic> sub) {
    return _$updateSubAsyncAction.run(() => super.updateSub(sub));
  }

  final _$addSubAsyncAction = AsyncAction('_LocalConfigStore.addSub');

  @override
  Future<void> addSub(Map<String, dynamic> sub) {
    return _$addSubAsyncAction.run(() => super.addSub(sub));
  }

  final _$removeSubAsyncAction = AsyncAction('_LocalConfigStore.removeSub');

  @override
  Future<void> removeSub(Map<String, dynamic> sub) {
    return _$removeSubAsyncAction.run(() => super.removeSub(sub));
  }

  final _$updateSubsAsyncAction = AsyncAction('_LocalConfigStore.updateSubs');

  @override
  Future<void> updateSubs() {
    return _$updateSubsAsyncAction.run(() => super.updateSubs());
  }

  final _$_LocalConfigStoreActionController =
      ActionController(name: '_LocalConfigStore');

  @override
  void regularlyUpdateSubs() {
    final _$actionInfo = _$_LocalConfigStoreActionController.startAction(
        name: '_LocalConfigStore.regularlyUpdateSubs');
    try {
      return super.regularlyUpdateSubs();
    } finally {
      _$_LocalConfigStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
clashApiAddress: ${clashApiAddress},
clashApiSecret: ${clashApiSecret}
    ''';
  }
}
