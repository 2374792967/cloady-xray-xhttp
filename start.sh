#!/bin/sh
set -e
if [ -z "$UUID" ]; then
  UUID="$(cat /proc/sys/kernel/random/uuid)"
  echo "UUID not set - generated UUID: $UUID"
fi
XPATH="${XHTTP_PATH:-xhttp-deefaa6715e3cb17}"
PORT="${PORT:-8080}"
if [ "$PORT" = "3000" ]; then
  ALT_PORT=8080
else
  ALT_PORT=3000
fi
cat > /etc/xray/config.json <<EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "$UUID"}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "none",
        "xhttpSettings": {"path": "/$XPATH", "mode": "stream"}
      }
    },
    {
      "port": $ALT_PORT,
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "$UUID"}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "none",
        "xhttpSettings": {"path": "/$XPATH", "mode": "stream"}
      }
    }
  ],
  "outbounds": [{"protocol": "freedom", "settings": {}}]
}
EOF
echo "xray listening on $PORT and $ALT_PORT, xhttp path /$XPATH"
exec /usr/bin/xray run -c /etc/xray/config.json
