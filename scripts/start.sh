#!/bin/bash
# 后台运行 Chat_on_webchat 执行脚本

cd "$(dirname "$0")/.."
export BASE_DIR="$(pwd)"
echo "$BASE_DIR"

detect_python_command() {
  for cmd in "${PYTHON_CMD:-}" python3.12 python3.11 python3.10 python3.9 python3.8 python3.7 python3 python; do
    [ -n "$cmd" ] || continue
    if command -v "$cmd" >/dev/null 2>&1; then
      major_version=$("$cmd" -c 'import sys; print(sys.version_info[0])' 2>/dev/null)
      minor_version=$("$cmd" -c 'import sys; print(sys.version_info[1])' 2>/dev/null)
      if [ "$major_version" = "3" ] && [ "$minor_version" -ge 9 ] && [ "$minor_version" -le 12 ]; then
        echo "$cmd"
        return 0
      fi
    fi
  done
  return 1
}

PYTHON_BIN="$(detect_python_command)" || {
  echo "No compatible Python found. Please install Python 3.12."
  exit 1
}

# check the nohup.out log output file
if [ ! -f "${BASE_DIR}/nohup.out" ]; then
  touch "${BASE_DIR}/nohup.out"
  echo "create file ${BASE_DIR}/nohup.out"
fi

nohup "$PYTHON_BIN" "${BASE_DIR}/app.py" & tail -f "${BASE_DIR}/nohup.out"

echo "Chat_on_webchat is starting with ${PYTHON_BIN}，you can check ${BASE_DIR}/nohup.out"
