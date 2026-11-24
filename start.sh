#!/usr/bin/env bash
# Marzban-on-Render boot script
# 1) Renders nginx config from template using $PORT and $WS_PATH (both come from Render env vars)
# 2) Injects $WS_PATH into the baked xray config
# 3) Starts nginx (router), then Marzban (panel + Xray core)

PORT="${PORT:-10000}"
WS_PATH="${WS_PATH:-/ws-render-123}"

# Ensure a single leading slash, no trailing slash (Xray matches the path exactly)
case "$WS_PATH" in
  /*) ;;
  *) WS_PATH="/${WS_PATH}" ;;
esac
WS_PATH="${WS_PATH%/}"

# Escape "&" for sed replacement
WS_PATH_ESC="${WS_PATH//&/\\&}"

echo "[start.sh] PORT=${PORT} | WS_PATH=${WS_PATH}"

sed -e "s|__PORT__|${PORT}|g" \
    -e "s|__WS_PATH__|${WS_PATH_ESC}|g" \
    /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

sed -i "s|__WS_PATH__|${WS_PATH_ESC}|g" /code/xray_config.json

# Start the router (nginx daemonizes by itself)
nginx

# Original Marzban container command
alembic upgrade head
exec python main.py
