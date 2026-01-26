#!/usr/bin/env bash
set -e

# Install Flutter (stable) into the Render build environment
git clone https://github.com/flutter/flutter.git --depth 1 -b stable
export PATH="$PWD/flutter/bin:$PATH"

flutter --version
flutter pub get
flutter build web --release

# SPA routing fix (important if you use Navigator routes like /home, /settings)
# Create a redirect rule so refreshing pages works.
echo "/*    /index.html   200" > build/web/_redirects
