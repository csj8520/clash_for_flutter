// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxies.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ProxiesStore on _ProxiesStore, Store {
  Computed<Map<String, ProxiesProxie>>? _$allProxiesComputed;

  @override
  Map<String, ProxiesProxie> get allProxies => (_$allProxiesComputed ??=
          Computed<Map<String, ProxiesProxie>>(() => super.allProxies,
              name: '_ProxiesStore.allProxies'))
      .value;
  Computed<List<String>>? _$timeoutProxiesComputed;

  @override
  List<String> get timeoutProxies => (_$timeoutProxiesComputed ??=
          Computed<List<String>>(() => super.timeoutProxies,
              name: '_ProxiesStore.timeoutProxies'))
      .value;

  final _$globalAtom = Atom(name: '_ProxiesStore.global');

  @override
  ProxiesProxyGroup? get global {
    _$globalAtom.reportRead();
    return super.global;
  }

  @override
  set global(ProxiesProxyGroup? value) {
    _$globalAtom.reportWrite(value, super.global, () {
      super.global = value;
    });
  }

  final _$groupsAtom = Atom(name: '_ProxiesStore.groups');

  @override
  List<ProxiesProxyGroup> get groups {
    _$groupsAtom.reportRead();
    return super.groups;
  }

  @override
  set groups(List<ProxiesProxyGroup> value) {
    _$groupsAtom.reportWrite(value, super.groups, () {
      super.groups = value;
    });
  }

  final _$proxiesAtom = Atom(name: '_ProxiesStore.proxies');

  @override
  List<ProxiesProxie> get proxies {
    _$proxiesAtom.reportRead();
    return super.proxies;
  }

  @override
  set proxies(List<ProxiesProxie> value) {
    _$proxiesAtom.reportWrite(value, super.proxies, () {
      super.proxies = value;
    });
  }

  final _$providersAtom = Atom(name: '_ProxiesStore.providers');

  @override
  List<ProxiesProviders> get providers {
    _$providersAtom.reportRead();
    return super.providers;
  }

  @override
  set providers(List<ProxiesProviders> value) {
    _$providersAtom.reportWrite(value, super.providers, () {
      super.providers = value;
    });
  }

  final _$updateAsyncAction = AsyncAction('_ProxiesStore.update');

  @override
  Future<void> update() {
    return _$updateAsyncAction.run(() => super.update());
  }

  final _$updateGroupAsyncAction = AsyncAction('_ProxiesStore.updateGroup');

  @override
  Future<void> updateGroup() {
    return _$updateGroupAsyncAction.run(() => super.updateGroup());
  }

  final _$updateProvidersAsyncAction =
      AsyncAction('_ProxiesStore.updateProviders');

  @override
  Future<void> updateProviders() {
    return _$updateProvidersAsyncAction.run(() => super.updateProviders());
  }

  final _$setProxieGroupAsyncAction =
      AsyncAction('_ProxiesStore.setProxieGroup');

  @override
  Future<void> setProxieGroup(String group, String value) {
    return _$setProxieGroupAsyncAction
        .run(() => super.setProxieGroup(group, value));
  }

  @override
  String toString() {
    return '''
global: ${global},
groups: ${groups},
proxies: ${proxies},
providers: ${providers},
allProxies: ${allProxies},
timeoutProxies: ${timeoutProxies}
    ''';
  }
}
