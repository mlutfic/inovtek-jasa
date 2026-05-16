#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="127.0.0.1"
PORT="8000"

usage() {
  cat <<EOF
Usage: ./script.sh [--host HOST] [--port PORT]

Menjalankan website statis dari folder ini di local server.

Options:
  --host HOST   Default: 127.0.0.1
  --port PORT   Default: 8000
  --help        Tampilkan bantuan
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      [[ $# -ge 2 ]] || {
        echo "Error: --host butuh nilai." >&2
        exit 1
      }
      HOST="$2"
      shift 2
      ;;
    --port)
      [[ $# -ge 2 ]] || {
        echo "Error: --port butuh nilai." >&2
        exit 1
      }
      PORT="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Error: argumen tidak dikenal: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "$ROOT_DIR/index.html" ]]; then
  echo "Error: index.html tidak ditemukan di $ROOT_DIR" >&2
  exit 1
fi

cd "$ROOT_DIR"

echo "Serving local site from: $ROOT_DIR"
echo "URL: http://$HOST:$PORT"

if command -v python3 >/dev/null 2>&1; then
  exec python3 -m http.server "$PORT" --bind "$HOST"
fi

if command -v python >/dev/null 2>&1; then
  exec python -m http.server "$PORT" --bind "$HOST"
fi

if command -v php >/dev/null 2>&1; then
  exec php -S "$HOST:$PORT"
fi

echo "Error: butuh salah satu dari python3, python, atau php untuk menjalankan server local." >&2
exit 1
