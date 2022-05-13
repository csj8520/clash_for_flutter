BUILD_DMG=flutter_distributor package --platform=macos --targets=dmg

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