# Fase 2 — Containerização

Esta branch parte da entrega da Fase 1. O Dockerfile executa o build com Node.js e copia apenas a pasta `dist/` para um servidor NGINX sem privilégios de administrador. As tarefas continuam guardadas no navegador.

## Deploy local

Com Docker em execução e `curl` instalado, execute na raiz do repositório:

```sh
sh scripts/deploy-container.sh
```

Abra `http://127.0.0.1:8080/`. A rota `/healthz` indica se o servidor está a responder. O script também verifica o HTML e o módulo JavaScript principal. O serviço só é exposto na máquina local. Para parar:

```sh
docker stop devops-tarefas
```

É possível escolher outras configurações por meio de `HOST_PORT`, `IMAGE_NAME` e `CONTAINER_NAME`. Por exemplo, `HOST_PORT=8081 sh scripts/deploy-container.sh`.

O workflow **Validar container (Fase 2)** executa o mesmo script num ambiente temporário do GitHub Actions. A publicação num ambiente de entrega será configurada numa etapa separada. Nenhum recurso AWS é criado por este script.
