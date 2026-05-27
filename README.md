# Gifnut Owner App

## 개발 실행

```bash
# dev flavor
flutter run --flavor dev -t lib/main_dev.dart

# prod flavor
flutter run --flavor prod -t lib/main_prod.dart
```

## 배포 빌드

### Android

```bash
# dev APK
flutter build apk --flavor dev -t lib/main_dev.dart --release \
  --obfuscate \
  --split-debug-info=build/debug-info/android

# prod APK
flutter build apk --flavor prod -t lib/main_prod.dart --release \
  --obfuscate \
  --split-debug-info=build/debug-info/android

# prod AAB (Play Store 업로드용)
flutter build appbundle --flavor prod -t lib/main_prod.dart --release \
  --obfuscate \
  --split-debug-info=build/debug-info/android
```

### iOS

```bash
# dev IPA
flutter build ipa --flavor dev -t lib/main_dev.dart --release \
  --obfuscate \
  --split-debug-info=build/debug-info/ios

# prod IPA
flutter build ipa --flavor prod -t lib/main_prod.dart --release \
  --obfuscate \
  --split-debug-info=build/debug-info/ios
```

> `--split-debug-info` 로 생성된 심볼 파일은 `build/debug-info/` 에 저장됩니다.
> Firebase Crashlytics 스택 트레이스 복원에 필요하므로 배포 시 보관하세요.

## 환경 변수

| Flavor | API Base URL | Payletter |
|--------|-------------|-----------|
| dev | `https://www.502company.com/dev` | Sandbox (`https://testppay.payletter.com`) |
| prod | `https://www.502company.com/prod` | Live (`https://ppay.payletter.com`) |
