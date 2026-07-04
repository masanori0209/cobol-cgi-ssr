#!/bin/bash
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${ZENN_IMAGES_DIR:-$ROOT/../m-zenn-dev/images}"
BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
LOG="$ROOT/reports/run-all.log"
VIEWPORT="${CAPTURE_VIEWPORT:-1280,800}"

mkdir -p "$OUT_DIR" "$ROOT/reports"

echo "== run-all (log) =="
BASE_URL="$BASE_URL" "$ROOT/scripts/run-all.sh" | tee "$LOG"

if ! command -v npx >/dev/null 2>&1; then
  echo "skip browser screenshots (npx not found)"
  exit 0
fi

shot() {
  local path="$1"
  local out="$2"
  echo "== screenshot $path -> $out =="
  npx --yes playwright screenshot \
    --viewport-size="$VIEWPORT" \
    "${BASE_URL}${path}" \
    "$OUT_DIR/$out"
}

shot "/" "cobol-cgi-ssr-home.png"
shot "/posts" "cobol-cgi-ssr-posts.png"
shot "/posts/1" "cobol-cgi-ssr-post-detail.png"
shot "/login" "cobol-cgi-ssr-login.png"
# 記事で既に参照しているファイル名（一覧画面）
cp "$OUT_DIR/cobol-cgi-ssr-posts.png" "$OUT_DIR/cobol-cgi-ssr-run-all.png"

echo "log: $LOG"
echo "images:"
ls -1 "$OUT_DIR"/cobol-cgi-ssr-*.png
