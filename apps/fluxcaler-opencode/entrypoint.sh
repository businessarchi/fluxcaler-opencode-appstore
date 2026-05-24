#!/usr/bin/env bash
set -e

DARIO_PORT="${DARIO_PORT:-3456}"
OPENCODE_PORT="${OPENCODE_PORT:-4096}"
DEFAULT_MODEL="${OPENCODE_DEFAULT_MODEL:-anthropic/claude-sonnet-4-6}"

OPENCODE_CONFIG_DIR="/root/.config/opencode"
mkdir -p "$OPENCODE_CONFIG_DIR"
if [ ! -f "$OPENCODE_CONFIG_DIR/opencode.json" ]; then
  cat > "$OPENCODE_CONFIG_DIR/opencode.json" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "${DEFAULT_MODEL}",
  "provider": {
    "anthropic": {
      "options": {
        "apiKey": "dario",
        "baseURL": "http://127.0.0.1:${DARIO_PORT}/v1"
      }
    }
  }
}
EOF
  echo "[entrypoint] opencode.json generated (model=${DEFAULT_MODEL})"
fi

mkdir -p /root/.dario

if [ ! -f /root/.dario/credentials.json ] && [ -z "$(ls -A /root/.dario 2>/dev/null | grep -v cc-template)" ]; then
  echo ""
  echo "============================================================"
  echo "  ⚠  PREMIER LANCEMENT — dario n'a pas encore de credentials"
  echo ""
  echo "  Ouvre un shell dans ce conteneur et lance :"
  echo "    docker exec -it fluxcaler-opencode dario login --manual"
  echo ""
  echo "  Une URL s'affichera : ouvre-la dans ton navigateur, autorise"
  echo "  ton compte Claude Pro/Max, puis colle le code de retour."
  echo "============================================================"
  echo ""
fi

echo "[entrypoint] starting dario proxy on :${DARIO_PORT}"
dario proxy > /var/log/dario.log 2>&1 &
DARIO_PID=$!

for i in 1 2 3 4 5 6 7 8 9 10; do
  if curl -sf "http://127.0.0.1:${DARIO_PORT}/health" > /dev/null 2>&1; then
    echo "[entrypoint] dario healthy"
    break
  fi
  sleep 1
done

echo "[entrypoint] starting opencode serve on 0.0.0.0:${OPENCODE_PORT}"
exec opencode serve --hostname 0.0.0.0 --port "${OPENCODE_PORT}"
