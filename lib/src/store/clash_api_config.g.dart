// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clash_api_config.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ClashApiConfigStore on _ClashApiConfigStore, Store {
  final _$configAtom = Atom(name: '_ClashApiConfigStore.config');

  @override
  Map<String, dynamic> get config {
    _$configAtom.reportRead();
    return super.config;
  }

  @override
  set config(Map<String, dynamic> value) {
    _$configAtom.reportWrite(value, super.config, () {
      super.config = value;
    });
  }

  final _$updateConfigAsyncAction =
      AsyncAction('_ClashApiConfigStore.updateConfig');

  @override
  Future<void> updateConfig() {
    return _$updateConfigAsyncAction.run(() => super.updateConfig());
  }

  final _$setAllowLanAsyncAction =
      AsyncAction('_ClashApiConfigStore.setAllowLan');

  @override
  Future<void> setAllowLan(bool value) {
    return _$setAllowLanAsyncAction.run(() => super.setAllowLan(value));
  }

  final _$setModeAsyncAction = AsyncAction('_ClashApiConfigStore.setMode');

  @override
  Future<void> setMode(String value) {
    return _$setModeAsyncAction.run(() => super.setMode(value));
  }

  @override
  String toString() {
    return '''
config: ${config}
    ''';
  }
}
