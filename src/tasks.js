export function addTask(tasks, description, id = String(Date.now())) {
  if (typeof description !== 'string' || !description.trim()) {
    throw new Error('A descrição da tarefa é obrigatória.');
  }
  return [...tasks, { id, description: description.trim(), completed: false }];
}

export function toggleTask(tasks, id) {
  return tasks.map(task => task.id === id ? { ...task, completed: !task.completed } : task);
}

export function deleteTask(tasks, id) {
  return tasks.filter(task => task.id !== id);
}

export function loadTasks(storage) {
  try {
    const data = JSON.parse(storage.getItem('tasks') || '[]');
    return Array.isArray(data) ? data : [];
  } catch {
    return [];
  }
}

export function saveTasks(storage, tasks) {
  storage.setItem('tasks', JSON.stringify(tasks));
}
