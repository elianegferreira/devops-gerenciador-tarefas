import assert from 'node:assert/strict';

const app = process.env.APP_URL ?? 'http://web:8080';

async function get(path, expectedStatus = 200) {
  const response = await fetch(new URL(path, app), {
    signal: AbortSignal.timeout(5000),
    redirect: 'error',
  });
  assert.equal(response.status, expectedStatus, path);
  return response;
}

assert.equal((await (await get('/healthz')).text()).trim(), 'ok');
console.log('OK /healthz');

const page = await get('/');
assert.match(await page.text(), /Minhas tarefas/);
assert.equal(page.headers.get('x-content-type-options'), 'nosniff');
console.log('OK página inicial e cabeçalho de segurança');

for (const path of ['/style.css', '/src/app.js', '/src/tasks.js']) {
  assert.ok((await (await get(path)).text()).length > 0, path);
  console.log(`OK ${path}`);
}

await get('/__arquivo_inexistente__', 404);
console.log('OK caminho inexistente responde com 404');
console.log('Verificação HTTP concluída com sucesso.');
