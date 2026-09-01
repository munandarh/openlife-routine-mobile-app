# Release Guide

How to cut a signed OpenLife Routine release. Everything here has been run
except the steps that need your own key or a Play account — those are marked.

---

## 1. The upload key (once, ever)

Google Play identifies your app by its signing key. **If you lose this key or
its password, you can never publish an update to that listing again.** Back both
up somewhere you will still have in five years.

```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Then copy the template and fill it in:

```bash
cp android/key.properties.example android/key.properties
```

```properties
storePassword=…
keyPassword=…
keyAlias=upload
storeFile=upload-keystore.jks      # relative to android/app/
```

`android/.gitignore` already excludes `key.properties`, `*.jks` and
`*.keystore`. Verify before your first commit:

```bash
git check-ignore -v android/key.properties android/app/upload-keystore.jks
```

### How the build picks it up

`android/app/build.gradle.kts` reads `android/key.properties` when it exists and
signs the release with it. When it does not exist the release build falls back
to the debug keys and logs a warning, so `flutter run --release` and CI still
work for contributors who do not have the upload key.

**A debug-signed artifact installs fine but Play will reject it.** Confirm what
you actually built before uploading:

```bash
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

The DN must be your own, not `CN=Android Debug`.

---

## 2. Pre-flight

```bash
flutter analyze     # must be 0 issues
flutter test        # must be green
```

Bump the version in `pubspec.yaml` and mirror it in
`lib/core/app_info.dart` — a test fails if the two drift apart. Add the release
section to `CHANGELOG.md`.

---

## 3. Build

```bash
# Play Store
flutter build appbundle --release

# Direct download / GitHub Releases — per ABI, ~45 MB each instead of a 91 MB
# fat APK
flutter build apk --release --split-per-abi
```

Artifacts:

- `build/app/outputs/bundle/release/app-release.aab`
- `build/app/outputs/flutter-apk/app-{armeabi-v7a,arm64-v8a,x86_64}-release.apk`

### Checks that have caught real problems here

```bash
# 16 KB page-size compatibility — required by Play for Android 15+.
# Every LOAD alignment must be 0x4000 or larger.
unzip -o build/app/outputs/flutter-apk/app-arm64-v8a-release.apk 'lib/*' -d /tmp/apk
for so in /tmp/apk/lib/arm64-v8a/*.so; do
  echo "$(basename "$so") $(llvm-readelf -l "$so" | awk '/LOAD/{print $NF}' | sort -u)"
done
```

```bash
# The notification icon is referenced only by name from Dart, so the resource
# shrinker will strip it unless res/raw/keep.xml holds it.
aapt2 dump resources build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
  | grep ic_notification
```

---

## 4. Smoke test the release build on a device

Debug builds do not exercise the shrinker, so these must be checked against the
release artifact:

```bash
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
adb logcat -c && adb shell monkey -p com.openlife.openlife_routine \
  -c android.intent.category.LAUNCHER 1
adb logcat -d | grep -iE "FATAL|Exception|16 KB|ELF alignment"
```

Then, by hand:

- [ ] First run: language → notification permission → 4 slides → starter template
- [ ] Picking Indonesian actually translates the next screen
- [ ] Create a routine a couple of minutes out and confirm the reminder fires
- [ ] Snooze from the notification reschedules it
- [ ] Tapping the notification opens that routine
- [ ] Delete the routine and confirm you land back on Today
- [ ] Switch language in Settings and confirm the whole app re-renders

To confirm a reminder is really queued:

```bash
adb shell dumpsys alarm | grep -A1 com.openlife.openlife_routine | grep origWhen=
```

---

## 5. Publish

```bash
git tag -a v1.1.0 -m "OpenLife Routine 1.1.0"
git push origin v1.1.0

gh release create v1.1.0 \
  build/app/outputs/flutter-apk/app-*-release.apk \
  --title "OpenLife Routine 1.1.0" \
  --notes-file CHANGELOG.md
```

Play Console (needs a developer account): upload the `.aab` to the internal
testing track first, and only promote once the smoke test above passes on a
real device.

---

## 6. Afterwards

- Move the shipped items in `docs/SPRINT-CHECKLIST.md`.
- Open the next milestone from [`../ROADMAP.md`](../ROADMAP.md).
- Keep the upload key backed up. It is the one thing here you cannot recreate.
