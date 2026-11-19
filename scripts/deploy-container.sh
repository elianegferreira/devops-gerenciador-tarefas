#!/usr/bin/env sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
image=${IMAGE_NAME:-devops-tarefas:local}
name=${CONTAINER_NAME:-devops-tarefas}
port=${HOST_PORT:-8080}
url="http://127.0.0.1:$port"

docker build --tag "$image" "$repo_dir"
container_id=$(docker run --rm --detach --name "$name" --publish "127.0.0.1:$port:8080" "$image")
status=1
cleanup() {
    if [ "$status" -ne 0 ]; then
        docker logs "$container_id" >&2 || true
        docker stop "$container_id" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

attempt=0
while [ "$attempt" -lt 30 ]; do
    if curl --fail --silent --max-time 2 "$url/healthz" >/dev/null; then
        curl --fail --silent --show-error --max-time 5 "$url/" | grep -Fq 'Minhas tarefas'
        curl --fail --silent --show-error --max-time 5 "$url/src/app.js" >/dev/null
        status=0
        printf 'Container %s disponível em %s/\n' "$name" "$url"
        exit 0
    fi
    attempt=$((attempt + 1))
    sleep 1
done
printf 'O container não respondeu à verificação em %s/healthz.\n' "$url" >&2
exit 1
