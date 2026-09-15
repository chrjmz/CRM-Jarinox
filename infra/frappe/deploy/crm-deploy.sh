#!/bin/bash
# Despliegue automatico del piloto CRM Jarinox.
# Revisa el repo y, si hay cambios nuevos, los aplica.
# Solo actua sobre el stack del CRM; nunca toca otros sitios del servidor.
set -euo pipefail

REPO=/opt/crm-jarinox
DEPLOY=$REPO/infra/frappe/deploy
LOG=/var/log/crm-deploy.log

log() { echo "[$(date "+%Y-%m-%d %H:%M:%S")] $*" >> "$LOG"; }

cd "$REPO"
git fetch -q origin main
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
  exit 0
fi

log "cambios detectados: ${LOCAL:0:7} -> ${REMOTE:0:7}"
git pull -q --ff-only origin main
log "repo actualizado"

# Solo reinicia el stack si cambio algo que le afecta.
if git diff --name-only "$LOCAL" "$REMOTE" | grep -qE "^infra/frappe/"; then
  cd "$DEPLOY"
  docker compose --env-file .env -f compose.prod.yaml -f compose.override.yaml up -d >> "$LOG" 2>&1
  log "stack actualizado"
else
  log "sin cambios en infra/frappe: no se reinicia el stack"
fi
