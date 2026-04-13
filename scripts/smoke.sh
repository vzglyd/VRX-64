#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PORT="${VRX64_SMOKE_PORT:-18080}"
BASE_URL="http://127.0.0.1:${PORT}"
SERVER_LOG="${TMPDIR:-/tmp}/vrx64-smoke-serve-${PORT}.log"

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "[smoke] installing Node dependencies if needed"
if [[ ! -d node_modules || ! -x node_modules/.bin/vite || ! -x node_modules/.bin/playwright ]]; then
  npm ci
fi

echo "[smoke] building React/TypeScript UI bundles"
npm run build:ui

echo "[smoke] building web host WASM"
wasm-pack build --target web --out-dir web-preview/pkg --no-opt VRX-64-web

echo "[smoke] building native host and loading bundle"
cargo build -p VRX-64-native

echo "[smoke] running shared Rust tests"
cargo test -p VRX-64-slide -p VRX-64-kernel

echo "[smoke] running native smoke tests"
cargo test -p VRX-64-native smoke

echo "[smoke] copying loading.vzglyd for browser harness"
VZGLYD="$(find target -name 'loading.vzglyd' -print -quit)"
if [[ -z "$VZGLYD" ]]; then
  echo "[smoke] loading.vzglyd was not produced" >&2
  exit 1
fi
cp "$VZGLYD" VRX-64-web/web-preview/loading.vzglyd

echo "[smoke] ensuring Playwright Chromium is installed"
npx playwright install chromium

echo "[smoke] serving preview on ${BASE_URL}"
npx serve -l "$PORT" . >"$SERVER_LOG" 2>&1 &
SERVER_PID="$!"
sleep 1

if ! kill -0 "$SERVER_PID" >/dev/null 2>&1; then
  echo "[smoke] preview server failed to start; log follows" >&2
  cat "$SERVER_LOG" >&2 || true
  exit 1
fi

echo "[smoke] running browser smoke test"
VRX64_SMOKE_BASE_URL="$BASE_URL" npx playwright test tests/web-smoke.spec.js

echo "[smoke] ok"
