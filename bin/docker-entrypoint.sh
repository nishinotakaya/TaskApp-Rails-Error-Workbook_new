#!/usr/bin/env bash
set -euo pipefail

# Rails server.pid が残っていると起動できない
rm -f /myapp/tmp/pids/server.pid

# DB は compose の healthcheck/depends_on で待つ想定
# 追加で待ちたい場合は以下をコメント解除（DB ホスト/パスワードは環境に合わせる）
# until mysqladmin ping -h "${DB_HOST:-db}" -p"${DB_PASSWORD:-password}" --silent; do
#   echo "Waiting for MySQL..." >&2
#   sleep 2
# done

# 最終的に CMD を実行
exec "$@"
