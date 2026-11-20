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
        "xhttpSettings": {"path": "/$XPATH"}
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
        "xhttpSettings": {"path": "/$XPATH"}
      }
    },
    {
      "port": 8443,
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "$UUID"}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "dest": "www.microsoft.com:443",
          "serverNames": ["www.microsoft.com"],
          "privateKey": "0GYKr0PvQMq90x5fvdhtapD5vWJa4ySP2rJAbTES82s",
          "shortIds": ["f8d524e6a9a0190d"]
        }
      }
    }
  ],
  "outbounds": [{"protocol": "freedom", "settings": {}}]
}
EOF
echo "xray listening on $PORT and $ALT_PORT (xhttp), 8443 (reality), xhttp path /$XPATH"
exec /usr/bin/xray run -c /etc/xray/config.json
