#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="${PWD}/.vercel_flutter"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
    git clone --depth 1 --branch stable \
      https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
  fi
  export PATH="${FLUTTER_DIR}/bin:${PATH}"
fi

: "${DEMO_MODE:=false}"
: "${SUPABASE_URL:?Configura SUPABASE_URL en Vercel}"
: "${SUPABASE_PUBLISHABLE_KEY:?Configura SUPABASE_PUBLISHABLE_KEY en Vercel}"

flutter config --enable-web
flutter pub get
flutter build web --release \
  --base-href=/ \
  --dart-define="DEMO_MODE=${DEMO_MODE}" \
  --dart-define="SUPABASE_URL=${SUPABASE_URL}" \
  --dart-define="SUPABASE_PUBLISHABLE_KEY=${SUPABASE_PUBLISHABLE_KEY}"
