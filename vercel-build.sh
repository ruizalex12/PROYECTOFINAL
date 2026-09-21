#!/bin/bash
set -e

git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"

export PATH="$PATH:$HOME/flutter/bin"

flutter config --enable-web
flutter pub get

flutter build web --release \
  --dart-define=DEMO_MODE="$DEMO_MODE" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY"