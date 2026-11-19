#!/usr/bin/env bash
set -euo pipefail

: "${RENDER_API_KEY:?Configure o secret RENDER_API_KEY no GitHub}"
: "${RENDER_SERVICE_ID:?Configure a variável RENDER_SERVICE_ID no GitHub}"
: "${RENDER_SERVICE_URL:?Configure a variável RENDER_SERVICE_URL no GitHub}"
: "${DEPLOY_COMMIT:?Informe o commit validado}"
[[ "$RENDER_SERVICE_ID" =~ ^srv-[a-zA-Z0-9]+$ ]] || { echo 'ID de serviço inválido.' >&2; exit 1; }
[[ "$RENDER_SERVICE_URL" =~ ^https://[a-zA-Z0-9-]+\.onrender\.com/?$ ]] || { echo 'Informe o endereço HTTPS do serviço no Render.' >&2; exit 1; }
[[ "$DEPLOY_COMMIT" =~ ^[a-f0-9]{40}$ ]] || { echo 'SHA do commit inválido.' >&2; exit 1; }

api="https://api.render.com/v1/services/$RENDER_SERVICE_ID/deploys"
auth=(-H "Authorization: Bearer $RENDER_API_KEY" -H 'Accept: application/json')
body=$(jq -nc --arg sha "$DEPLOY_COMMIT" '{commitId: $sha}')
response=$(curl -fsS --max-time 30 "${auth[@]}" -H 'Content-Type: application/json' --data "$body" "$api")
id=$(jq -er '.id | select(type == "string" and test("^dep-[a-zA-Z0-9]+$"))' <<<"$response")
echo "Deploy solicitado para $DEPLOY_COMMIT ($id)."

for ((attempt=1; attempt<=50; attempt++)); do
  response=$(curl -fsS --retry 2 --max-time 15 "${auth[@]}" "$api/$id")
  status=$(jq -er '.status | strings' <<<"$response")
  echo "Render: $status"
  case "$status" in
    live)
      jq -e --arg sha "$DEPLOY_COMMIT" '.commit.id == $sha' <<<"$response" >/dev/null
      url="${RENDER_SERVICE_URL%/}"
      health=$(curl -fsS --retry 3 --max-time 20 "$url/healthz")
      [[ "$health" == ok ]]
      html=$(curl -fsS --retry 3 --max-time 20 "$url/")
      [[ "$html" == *"Minhas tarefas"* ]]
      curl -fsS --retry 3 --max-time 20 "$url/src/app.js" >/dev/null
      printf 'Commit publicado e verificado em %s/\n' "$url"
      if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
        printf '### Deploy verificado\n\n- Commit: `%s`\n- Deploy: `%s`\n- Aplicação: %s/\n' "$DEPLOY_COMMIT" "$id" "$url" >>"$GITHUB_STEP_SUMMARY"
      fi
      exit 0
      ;;
    build_failed|update_failed|pre_deploy_failed|canceled|deactivated)
      echo "Deploy não concluído ($status)." >&2
      exit 1
      ;;
    created|queued|build_in_progress|pre_deploy_in_progress|update_in_progress) ;;
    *) echo "Estado inesperado: $status" >&2; exit 1 ;;
  esac
  sleep 10
done
echo 'O Render não confirmou o deploy dentro do tempo previsto.' >&2
exit 1
