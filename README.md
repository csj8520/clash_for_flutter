# ClashF Pro

### dev

```
flutter run -d windows

# https://mobx.netlify.app/getting-started
# generates *.g.dart
flutter pub run build_runner build
# or
flutter pub run build_runner watch
```

### build

```
flutter build windows
flutter pub run msix:create
```

#### build for mac
```
dart pub global activate flutter_distributor
npm install -g appdmg
flutter_distributor package --platform=macos --targets=dmg
```

## Question Record

### Hide cmd window

https://github.com/flutter/flutter/issues/47891#issuecomment-708850435

https://github.com/flutter/flutter/issues/47891#issuecomment-869729956

https://github.com/dart-lang/sdk/issues/39945#issuecomment-870428151

### bitsdojo_window fix macos run error

https://github.com/bitsdojo/bitsdojo_window/issues/119#issuecomment-997190458

### bitsdojo_window example

https://github.com/bitsdojo/bitsdojo_window/tree/master/bitsdojo_window/example

### close window not exit process for win

https://github.com/antler119/system_tray/issues/7#issuecomment-896905693

### close window not exit process for mac

https://github.com/antler119/system_tray/issues/10#issuecomment-905212027

### single-instance app for win

https://github.com/biyidev/biyi/commit/66ad34c21c221460c0bd7c47a743259f5e15a38d

## TODO FIX

- [ ] macos 关闭窗口时隐藏 dock

- [ ] hot restart 时重启 clash
      https://github.com/flutter/flutter/issues/10437

- [ ] macos debug 模式下多次调用 Shell 会卡死
      https://github.com/flutter/flutter/issues/95805

- [ ] clash pro 最新语法支持
  https://github.com/tindy2013/subconverter/issues/442

## Other Clash GUI

### ClashX for mac

https://github.com/yichengchen/clashX

### ClashX Pro for mac

https://install.appcenter.ms/users/clashx/apps/clashx-pro/distribution_groups/public

### Clash Pro for win & mac

https://github.com/Fndroid/clash_for_windows_pkg/

## sub converter

https://github.com/tindy2013/subconverter

### sub converter for web

https://github.com/CareyWang/sub-web/
