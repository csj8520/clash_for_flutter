BUILD_DMG=flutter_distributor package --platform macos --targets dmg
BUILD_EXE=flutter_distributor package --platform windows --targets exe

init-arm64:
	flutter pub get
	dart run --define=OS_ARCH=arm64 ./scripts/init.dart

init-amd64:
	flutter pub get
	dart run --define=OS_ARCH=amd64 ./scripts/init.dart


build-darwin-arm64:
	${BUILD_DMG} --build-dart-define=OS_ARCH=arm64

build-darwin-amd64:
	${BUILD_DMG} --build-dart-define=OS_ARCH=amd64

build-windows-arm64:
	${BUILD_EXE} --build-dart-define=OS_ARCH=arm64

build-windows-amd64:
	${BUILD_EXE} --build-dart-define=OS_ARCH=amd64