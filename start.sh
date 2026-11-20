#!/bin/sh
set -e
UUID="${UUID:?UUID environment variable is required}"
XPATH="${XHTTP_PATH:-xhttp-deefaa6715e3cb17}"
PORT="${PORT:-8080}"
cat > /etc/xray/config.json <<EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [
          {"id": "$UUID"}
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "none",
        "xhttpSettings": {
          "path": "/$XPATH",
          "mode": "stream"
        }
      }
    }
  ],
  "outbounds": [
    {"protocol": "freedom", "settings": {}}
  ]
}
EOF
exec /usr/bin/xray run -c /etc/xray/config.json
