#!/bin/bash
set -eu
cd "$(dirname "$0")/.."
if command -v cobc >/dev/null 2>&1; then
  ./scripts/build.sh
else
  echo "skip local build (cobc not found; use docker compose)"
fi
./scripts/count-lines.sh

BASE="${BASE_URL:-http://127.0.0.1:8080}"
COOKIE_JAR="$(mktemp)"
trap 'rm -f "$COOKIE_JAR"' EXIT

echo "== GET / =="
curl -sS "$BASE/" | sed -n '1,18p'
echo
echo "== GET /posts =="
curl -sS "$BASE/posts" | sed -n '1,22p'
echo
echo "== POST /login (session) =="
curl -sS -D - -o /dev/null -c "$COOKIE_JAR" \
  -X POST "$BASE/login" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'username=demo-user' | sed -n '1,8p'
echo
echo "== GET /posts/new (with cookie) =="
curl -sS -b "$COOKIE_JAR" "$BASE/posts/new" | sed -n '1,22p'
echo
echo "== POST /posts/new =="
curl -sS -D - -o /dev/null -b "$COOKIE_JAR" \
  -X POST "$BASE/posts/new" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'title=Posted%20from%20COBOL&body=Indexed%20file%20persistence%20works.' | sed -n '1,6p'
echo
echo "== GET /posts (after create) =="
curl -sS -b "$COOKIE_JAR" "$BASE/posts" | sed -n '1,28p'
echo
echo "== bench: 10x GET / (CGI cold-ish) =="
START=$(python3 -c 'import time; print(time.time())')
for i in $(seq 1 10); do
  curl -sS -o /dev/null "$BASE/"
done
END=$(python3 -c 'import time; print(time.time())')
python3 -c "print(f'10 requests in {float('$END')-float('$START'):.3f}s (spawn-per-request CGI)')"
echo
echo "done"
