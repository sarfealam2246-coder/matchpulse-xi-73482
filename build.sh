#!/usr/bin/env bash
set -euo pipefail

mkdir -p _src_backup dist
cp -r lib pubspec.yaml assets _src_backup/

flutter create . --org com.sarfealam --project-name matchpulse_xi --platforms=android

rm -rf lib pubspec.yaml assets
cp -r _src_backup/lib _src_backup/pubspec.yaml _src_backup/assets .
rm -rf _src_backup

# Inject INTERNET permission and App Label into AndroidManifest.xml
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
    sed -i 's/<application/<uses-permission android:name="android.permission.INTERNET"\/>\n    <application/' "$MANIFEST"
  fi
  sed -i 's/android:label="[^"]*"/android:label="MatchPulse XI"/' "$MANIFEST"
fi

# Generate Android Launcher Icons from Brand Symbol SVG
if [ -f "assets/icon.svg" ]; then
  for sz_dir in "48:mipmap-mdpi" "72:mipmap-hdpi" "96:mipmap-xhdpi" "144:mipmap-xxhdpi" "192:mipmap-xxxhdpi"; do
    sz="${sz_dir%%:*}"
    dir="${sz_dir##*:}"
    mkdir -p "android/app/src/main/res/$dir"
    convert -background none -resize "${sz}x${sz}" assets/icon.svg "android/app/src/main/res/$dir/ic_launcher.png" || true
  done
fi

flutter pub get
flutter analyze --no-fatal-infos || true
flutter build apk --release

cp build/app/outputs/flutter-apk/app-release.apk "dist/matchpulse_xi_release.apk"
echo "APK BUILT: dist/matchpulse_xi_release.apk"
