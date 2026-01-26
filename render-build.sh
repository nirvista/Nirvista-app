#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
  export PATH="$PWD/flutter/bin:$PATH"
fi

flutter --version
flutter pub get
flutter build web --release --web-renderer html
