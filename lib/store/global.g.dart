// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$GlobalStore on _GlobalStore, Store {
  final _$initedAtom = Atom(name: '_GlobalStore.inited');

  @override
  bool get inited {
    _$initedAtom.reportRead();
    return super.inited;
  }

  @override
  set inited(bool value) {
    _$initedAtom.reportWrite(value, super.inited, () {
      super.inited = value;
    });
  }

  final _$clashVersionAtom = Atom(name: '_GlobalStore.clashVersion');

  @override
  ClashVersion? get clashVersion {
    _$clashVersionAtom.reportRead();
    return super.clashVersion;
  }

  @override
  set clashVersion(ClashVersion? value) {
    _$clashVersionAtom.reportWrite(value, super.clashVersion, () {
      super.clashVersion = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_GlobalStore.init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$restartClashAsyncAction = AsyncAction('_GlobalStore.restartClash');

  @override
  Future<void> restartClash() {
    return _$restartClashAsyncAction.run(() => super.restartClash());
  }

  final _$initConfigAsyncAction = AsyncAction('_GlobalStore.initConfig');

  @override
  Future<void> initConfig() {
    return _$initConfigAsyncAction.run(() => super.initConfig());
  }

  final _$initClashAsyncAction = AsyncAction('_GlobalStore.initClash');

  @override
  Future<void> initClash() {
    return _$initClashAsyncAction.run(() => super.initClash());
  }

  final _$setProxyAsyncAction = AsyncAction('_GlobalStore.setProxy');

  @override
  Future<void> setProxy(bool value) {
    return _$setProxyAsyncAction.run(() => super.setProxy(value));
  }

  @override
  String toString() {
    return '''
inited: ${inited},
clashVersion: ${clashVersion}
    ''';
  }
}
