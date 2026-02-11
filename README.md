## Project_Management_For_Small_Teams
Система управления проектами для малых команд

# Описание проекта
База данных для системы управления проектами, командами и задачами в компании. Система позволяет отслеживать прогресс проектов, распределять задачи между сотрудниками, контролировать сроки и анализировать рабочую нагрузку.

# Структура базы данных
Основные таблицы:
|Таблица|Описание|Ключевые поля|
|-------|--------|-------------|
|users|Пользователи системы|id, email, username, role|
|teams|Команды/отделы|id, name, owner_id|
|team_members|Состав команд|team_id, user_id, role|
|projects|Проекты компании|id, name, team_id, manager_id, status, deadline|
|tasks|Задачи в проектах|id, title, project_id, status, priority, assignee_id|
|subtasks|Подзадачи|id, task_id, is_completed, assignee_id|
|time_entries|Учет рабочего времени|task_id, user_id, hours_spent, entry_date|
|attachments|Файлы и вложения|filename, file_url, task_id, project_id|

# Создание базы данных
>CREATE DATABASE Project_Management_For_Small_Teams;

# Инициализация схемы
>Выполните SQL-скрипт создания таблиц из файла create_tables.sql

# Наполнение тестовыми данными
>Выполните SQL-скрипт с INSERT-запросами для заполнения тестовыми данными из файла insert_data.sql

# Ключевые представления:
>Активные задачи по сотрудникам
```
SELECT * FROM view_employee_active_tasks
```
>Прогресс проектов
```
SELECT * FROM view_project_progress
```
>Временные затраты по проектам
```
SELECT * FROM view_project_time_tracking
```

# **Полезные отчеты** :
>Найти перегруженных сотрудников
```
SELECT * FROM view_employee_active_tasks 
WHERE task_status = 'in_progress' 
ORDER BY user_id;
```

>Просроченные задачи по отделам
```
SELECT team_name, COUNT(*) as overdue_tasks
FROM view_employee_active_tasks 
WHERE is_overdue = true
GROUP BY team_name;
```

>Найти проекты с низким процентом завершения
```
SELECT * FROM view_project_progress 
WHERE completion_percentage < 50 
AND project_status = 'active';
```

>Найти проекты, где фактические затраты превышают оценку
```
SELECT * FROM view_project_time_tracking 
WHERE estimated_vs_actual_percent > 100;
```

# Дополнительные ресурсы:
>Индексы для оптимизации
```
CREATE INDEX idx_tasks_project_status ON tasks(project_id, status);
CREATE INDEX idx_tasks_assignee_status ON tasks(assignee_id, status);
CREATE INDEX idx_time_entries_user_date ON time_entries(user_id, entry_date);
CREATE INDEX idx_projects_team_status ON projects(team_id, status);
```

# Дополнительная информация
>Частые проблемы и решения:
1. Медленные запросы - проверьте индексы, используйте EXPLAIN ANALYZE
2. Дублирование данных - добавьте UNIQUE constraints

Версия: 1.0.0
Дата проекта: Январь 2026
СУБД: PostgreSQL 18
