# Gerenciador de Tarefas — Projeto DevOps

Projeto acadêmico da disciplina **DevOps na Prática — Fase 1: Configuração e Automação Inicial**.

## Aplicação

Aplicação web estática em HTML, CSS e JavaScript para cadastrar, listar, concluir/reabrir e excluir tarefas. Os dados são armazenados no `localStorage` do navegador.

## Integração contínua

O workflow [CI](.github/workflows/ci.yml) é executado em `push` e `pull_request` para `main`, além de execução manual. As etapas são: preparar Node.js 22, executar `npm ci`, `npm test`, `npm run build` e guardar o artefato `dist/`.

Os testes automatizados estão em [tests/tasks.test.js](tests/tasks.test.js).

## Executar localmente

É possível abrir `index.html` num servidor HTTP estático (necessário porque a aplicação usa módulos JavaScript). Para validar o projeto com Node.js 22:

```sh
npm ci
npm test
npm run build
```

O build gera os arquivos estáticos na pasta `dist/`.

## Infraestrutura como código (IaC)

A pasta [infra/](infra/) contém arquivos Terraform para descrever um bucket privado no Amazon S3 com bloqueio de acesso público, versionamento e criptografia SSE-S3.

Para validar a configuração, com Terraform instalado:

```sh
cd infra
terraform fmt -check
terraform init -backend=false
terraform validate
```

O provisionamento efetivo **não é realizado automaticamente**: exige uma conta AWS, credenciais autorizadas, nome único do bucket e avaliação de custos. Não publicar credenciais, estados Terraform ou arquivos de variáveis sensíveis.

## Escopo

Nesta fase: documentação, código, testes, GitHub Actions e scripts IaC. A implantação contínua e containerização serão desenvolvidas na Fase 2.
