import test from 'node:test';
import assert from 'node:assert/strict';
import { addTask, toggleTask, deleteTask, loadTasks, saveTasks } from '../src/tasks.js';

test('cadastra tarefa com descrição válida', () => {
  assert.deepEqual(addTask([], ' Estudar DevOps ', '1'), [
    { id: '1', description: 'Estudar DevOps', completed: false }
  ]);
});

test('rejeita descrição vazia', () => {
  assert.throws(() => addTask([], '   '), /obrigatória/);
});

test('alterna entre pendente e concluída', () => {
  const tasks = addTask([], 'Estudar', '1');
  const completed = toggleTask(tasks, '1');
  assert.equal(completed[0].completed, true);
  assert.equal(toggleTask(completed, '1')[0].completed, false);
});

test('exclui apenas a tarefa selecionada', () => {
  const tasks = addTask(addTask([], 'A', '1'), 'B', '2');
  assert.deepEqual(deleteTask(tasks, '1').map(t => t.id), ['2']);
});

test('salva e recupera tarefas', () => {
  const map = new Map();
  const storage = { getItem: key => map.get(key) ?? null, setItem: (key, value) => map.set(key, value) };
  const tasks = addTask([], 'Persistência', '1');
  saveTasks(storage, tasks);
  assert.deepEqual(loadTasks(storage), tasks);
});

test('dados inválidos no armazenamento não quebram a aplicação', () => {
  assert.deepEqual(loadTasks({ getItem: () => '{invalido' }), []);
});
