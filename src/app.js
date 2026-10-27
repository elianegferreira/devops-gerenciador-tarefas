import { addTask, toggleTask, deleteTask, loadTasks, saveTasks } from './tasks.js';

const form = document.querySelector('#task-form');
const input = document.querySelector('#description');
const list = document.querySelector('#task-list');
const feedback = document.querySelector('#feedback');
let tasks = loadTasks(localStorage);

function render() {
  list.replaceChildren();
  for (const task of tasks) {
    const item = document.createElement('li');
    const title = document.createElement('span');
    title.textContent = task.description;
    if (task.completed) title.classList.add('done');

    const toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.textContent = task.completed ? 'Reabrir' : 'Concluir';
    toggle.addEventListener('click', () => {
      tasks = toggleTask(tasks, task.id);
      persist();
    });

    const remove = document.createElement('button');
    remove.type = 'button';
    remove.textContent = 'Excluir';
    remove.addEventListener('click', () => {
      tasks = deleteTask(tasks, task.id);
      persist();
    });
    item.append(title, toggle, remove);
    list.append(item);
  }
}

function persist() {
  saveTasks(localStorage, tasks);
  render();
}

form.addEventListener('submit', event => {
  event.preventDefault();
  try {
    tasks = addTask(tasks, input.value, crypto.randomUUID());
    input.value = '';
    feedback.textContent = '';
    persist();
  } catch (error) {
    feedback.textContent = error.message;
  }
});

render();
