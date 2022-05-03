# Clash For Flutter
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fcsj8520%2Fclash_for_flutter.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fcsj8520%2Fclash_for_flutter?ref=badge_shield)


### dev

```bash
# https://mobx.netlify.app/getting-started
# generates *.g.dart
flutter pub run build_runner build --delete-conflicting-outputs
# or
flutter pub run build_runner watch --delete-conflicting-outputs

flutter run -d windows
```

#### build for mac

```bash
dart pub global activate flutter_distributor
npm install -g appdmg
flutter_distributor package --platform=macos --targets=dmg
```

#### build for window

```bash
dart pub global activate flutter_distributor
# need install Inno https://jrsoftware.org/isdl.php#stable
flutter_distributor package --platform windows --targets exe,zip
```

#### build for window use Inno Setup

```
start "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" .\setup.iss
```

## Question Record

### MacOS tun 模式需要手动添加 dns

```bash
networksetup -getdnsservers Wi-Fi # get
networksetup -setdnsservers Wi-Fi 198.18.0.2 # set
networksetup -setdnsservers Wi-Fi empty # del
```

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

### edit windows version

https://github.com/flutter/flutter/issues/73652

## TODO

- [ ] macos 关闭窗口时隐藏 dock

- [x] hot restart 时重启 clash
      https://github.com/flutter/flutter/issues/10437

- [ ] macos debug 模式下多次调用 Shell 会卡死
      https://github.com/flutter/flutter/issues/95805

- [ ] tun 模式

## Other Clash GUI

### ClashX for mac

https://github.com/yichengchen/clashX

### ClashX Pro for mac

https://install.appcenter.ms/users/clashx/apps/clashx-pro/distribution_groups/public

### Clash Pro for win & mac

https://github.com/Fndroid/clash_for_windows_pkg/

## subconverter

https://github.com/tindy2013/subconverter

### subconverter web gui

https://github.com/CareyWang/sub-web/

### clash pro vmess 最新参数支持

https://github.com/tindy2013/subconverter/issues/442


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fcsj8520%2Fclash_for_flutter.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fcsj8520%2Fclash_for_flutter?ref=badge_large)