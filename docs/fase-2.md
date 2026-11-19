# Fase 2 — Containerização, orquestração e entrega contínua

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

## Orquestração com Docker Compose

O arquivo [compose.yaml](../compose.yaml) coordena dois containers numa rede local. O serviço `web` constrói e executa a imagem da aplicação. O serviço `verificacao` é temporário e só inicia após o `web` ficar saudável, com `depends_on` e `service_healthy`. O healthcheck verifica que o processo roda sem privilégios de administrador e que `/healthz` devolve `ok`.

Com Docker e Docker Compose disponíveis, execute na raiz:

```sh
sh scripts/test-compose.sh
```

O script valida a configuração, sobe os dois serviços, devolve o código de saída do verificador e remove os containers e a rede temporária ao terminar. O verificador testa a página inicial, CSS, JavaScript, cabeçalho de segurança e resposta 404. Se algum teste falhar, o GitHub Actions não publica.

Para demonstrar só a aplicação no navegador:

```sh
docker compose up --build --detach
# Abra http://127.0.0.1:8080/
docker compose down
```

Feche antes outro serviço local que esteja a usar a porta 8080 ou use `HOST_PORT=8081`. Os testes HTTP não substituem testes das ações do utilizador no navegador. O Compose é utilizado localmente e no GitHub Actions. O Render continua a executar apenas o serviço web a partir do Dockerfile.

## Entrega contínua no Render

O workflow **CI/CD (Fase 2)** executa os testes da aplicação, gera o build, valida o Terraform sem criar recursos e verifica o container. Com a publicação ativada, envia ao Render o SHA exato do commit aprovado, aguarda o estado `live` e confere o endereço público, a rota `/healthz` e o módulo JavaScript principal.

1. Crie um **Web Service** Docker no Render ligado a este repositório, na branch `fase-2`. Deixe o Dockerfile na raiz e configure o Health Check Path como `/healthz`. Defina `PORT=8080`. Escolha **Free** se disponível e desligue **Auto-Deploy** para que os próximos deploys sejam iniciados pelo GitHub Actions. A criação inicial do serviço pode disparar um primeiro deploy e não conta como evidência da entrega automatizada.
2. No GitHub, em **Settings → Secrets and variables → Actions**, guarde a chave de API do Render como secret `RENDER_API_KEY`. Configure as variáveis `RENDER_SERVICE_ID` (ID `srv-…`), `RENDER_SERVICE_URL` (URL HTTPS pública `*.onrender.com`) e, por último, `RENDER_DEPLOY_ENABLED=true`.
3. Envie um commit para a branch `fase-2` para acionar o workflow. Em **Actions → CI/CD (Fase 2)**, confirme o job de publicação e o link no resumo.

Enquanto `RENDER_DEPLOY_ENABLED` não for `true`, a publicação é pulada e nenhuma chamada é enviada ao Render. Consulte os logs do NGINX no job de validação e os logs do serviço no Render depois da publicação. Não inclua a chave de API no repositório nem nas capturas.

### Serviço da demonstração

O serviço Docker usa a branch `fase-2`, porta 8080 e verificação HTTP em `/healthz`. A publicação automática nativa do Render fica desativada. A aplicação está disponível em https://devops-gerenciador-tarefas.onrender.com/.
