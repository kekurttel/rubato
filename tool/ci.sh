#!/usr/bin/env bash
# Aurora CI gate (spec Phase 0, task 0.5): analyze + test.
#
# Usage:
#   tool/ci.sh          # full gate
#   tool/ci.sh analyze  # analyze only
#   tool/ci.sh test     # test only
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES=(
  packages/core
  packages/database
  packages/music_source
  packages/music_source_local
  packages/music_source_fake
  packages/music_source_ytdlp
  packages/downloads
  packages/playback
  packages/reco
  packages/ui_kit
  apps/aurora_mobile
)
MODE="${1:-all}"

graze() {
  echo '==> [graze] forbidden-import check (spec section 1)'
  # reco must never import network or UI libraries. yt-dlp access lives
  # only in music_source_ytdlp, which reco must not touch either.
  if [[ -d "$ROOT/packages/reco" ]]; then
    if grep -rEn \
      -e "import 'package:(http|dio|flutter)/" \
      -e 'import .*widgets\.dart' \
      -e 'music_source_ytdlp' \
      "$ROOT/packages/reco/lib" "$ROOT/packages/reco/test" 2>/dev/null; then
      echo 'FAIL: forbidden import found in packages/reco' >&2
      exit 1
    fi
    echo '    reco: clean'
  else
    echo '    packages/reco not present yet — graze skipped'
  fi
  # UI must never import Drift tables directly (only repositories).
  if [[ -d "$ROOT/packages/database" ]]; then
    for ui in "$ROOT/apps/aurora_mobile/lib" "$ROOT/packages/ui_kit/lib"; do
      [[ -d "$ui" ]] || continue
      if grep -rEn -e 'package:aurora_database/.*(tables|aurora_db)' \
        "$ui" 2>/dev/null; then
        echo "FAIL: UI imports Drift internals under $ui" >&2
        exit 1
      fi
    done
    echo '    ui-vs-drift: clean'
  else
    echo '    packages/database not present yet — ui-vs-drift skipped'
  fi
}

pub_get() {
  echo '==> [get] flutter pub get'
  for pkg in "${PACKAGES[@]}"; do
    [[ -d "$ROOT/$pkg" ]] || continue
    echo "    $pkg"
    (cd "$ROOT/$pkg" && flutter pub get)
  done
}

codegen() {
  echo '==> [gen] build_runner (packages with codegen)'
  if [[ -d "$ROOT/packages/core" ]]; then
    (cd "$ROOT/packages/core" &&
      dart run build_runner build --delete-conflicting-outputs)
  fi
}

analyze() {
  echo '==> [analyze] flutter analyze (0 issues required)'
  for pkg in "${PACKAGES[@]}"; do
    [[ -d "$ROOT/$pkg" ]] || continue
    echo "    $pkg"
    (cd "$ROOT/$pkg" && flutter analyze --no-pub)
  done
}

format_check() {
  echo '==> [format] dart format --set-exit-if-changed'
  local -a dirs=()
  for pkg in "${PACKAGES[@]}"; do
    [[ -d "$ROOT/$pkg/lib" ]] && dirs+=("$ROOT/$pkg/lib")
    [[ -d "$ROOT/$pkg/test" ]] && dirs+=("$ROOT/$pkg/test")
  done
  dart format --line-length 80 --set-exit-if-changed "${dirs[@]}"
}

run_tests() {
  echo '==> [test] flutter test'
  for pkg in "${PACKAGES[@]}"; do
    [[ -d "$ROOT/$pkg" ]] || continue
    echo "    $pkg"
    (cd "$ROOT/$pkg" && flutter test --no-pub)
  done
}

android_manifest_reminder() {
  local manifest="$ROOT/apps/aurora_mobile/android/app/src/main/AndroidManifest.xml"
  if [[ -f "$manifest" ]]; then
    grep -q 'android.permission.INTERNET' "$manifest" \
      || { echo 'FAIL: INTERNET permission missing (yt-dlp provider)' >&2
        exit 1; }
    grep -q 'android.permission.READ_MEDIA_AUDIO' "$manifest" \
      || echo 'WARN: READ_MEDIA_AUDIO permission missing (local scan)'
  else
    echo 'NOTE: Android shell not scaffolded yet — when it is, declare:'
    echo '  <uses-permission android:name="android.permission.INTERNET" />'
    echo '  <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />'
  fi
}

case "$MODE" in
  all)
    graze && pub_get && codegen && analyze && format_check && run_tests &&
      android_manifest_reminder && echo 'AURORA CI: ALL GREEN'
    ;;
  analyze)
    graze && analyze && format_check
    ;;
  test)
    run_tests
    ;;
  *) echo "unknown mode: $MODE (expected all|analyze|test)" >&2; exit 2 ;;
esac
