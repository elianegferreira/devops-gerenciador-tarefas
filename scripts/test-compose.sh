#!/usr/bin/env sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_dir"
project="devops-verificacao-$$"

compose() {
    docker compose --project-name "$project" --profile verificacao "$@"
}

cleanup() {
    compose ps --all || true
    compose down --remove-orphans || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

compose config --quiet
compose up --build --abort-on-container-exit --exit-code-from verificacao
