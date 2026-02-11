--Активные задачи по сотрудникам
  --Количество активных задач на сотрудника
  --Статусы задач (in_progress, todo)
  --Приоритеты задач
  --Просроченные задачи
  --Проекты, к которым относятся задачи

CREATE VIEW view_employee_active_tasks AS
SELECT 
    u.id as user_id,
    u.full_name,
    u.role as user_role,
    t.id as task_id,
    t.title as task_title,
    t.status as task_status,
    t.priority,
    t.due_date,
    p.name as project_name,
    p.status as project_status,
    teams.name as team_name,
    CASE 
        WHEN t.due_date < CURRENT_DATE AND t.status NOT IN ('completed') 
        THEN true 
        ELSE false 
    END as is_overdue
FROM users u
LEFT JOIN tasks t ON t.assignee_id = u.id
LEFT JOIN projects p ON t.project_id = p.id
LEFT JOIN teams ON p.team_id = teams.id
WHERE t.status NOT IN ('completed') 
    AND u.is_active = true
ORDER BY 
    u.full_name,
    CASE t.priority 
        WHEN 'high' THEN 1
        WHEN 'medium' THEN 2
        WHEN 'low' THEN 3
        ELSE 4
    END,
    t.due_date ASC;

--Пример использования представления: 
--найти перегруженных сотрудников
SELECT * FROM view_employee_active_tasks 
WHERE task_status = 'in_progress' 
ORDER BY user_id;
--просроченные задачи по отделам
SELECT team_name, COUNT(*) as overdue_tasks
FROM view_employee_active_tasks 
WHERE is_overdue = true
GROUP BY team_name;



--Прогресс проектов
  --Общее количество задач в проекте
  --Процент завершения задач
  --Распределение задач по статусам
  --Статус дедлайна (просрочен, скоро дедлайн, по графику)
  --Информация о команде и менеджере

CREATE VIEW view_project_progress AS
SELECT 
    p.id as project_id,
    p.name as project_name,
    p.status as project_status,
    p.start_date,
    p.deadline,
    t.name as team_name,
    u.full_name as manager_name,
    COUNT(tasks.id) as total_tasks,
    SUM(CASE WHEN tasks.status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
    SUM(CASE WHEN tasks.status = 'in_progress' THEN 1 ELSE 0 END) as in_progress_tasks,
    SUM(CASE WHEN tasks.status = 'todo' THEN 1 ELSE 0 END) as pending_tasks,
    ROUND(
        (SUM(CASE WHEN tasks.status = 'completed' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(tasks.id), 0)), 
        2
    ) as completion_percentage,
    CASE 
        WHEN p.deadline < CURRENT_DATE AND p.status != 'completed' 
        THEN 'Просрочен'
        WHEN p.deadline <= CURRENT_DATE + INTERVAL '7 days' AND p.status != 'completed'
        THEN 'Скоро дедлайн'
        ELSE 'По графику'
    END as deadline_status
FROM projects p
LEFT JOIN tasks ON tasks.project_id = p.id
LEFT JOIN teams t ON p.team_id = t.id
LEFT JOIN users u ON p.manager_id = u.id
GROUP BY 
    p.id, p.name, p.status, p.start_date, p.deadline, 
    t.name, u.full_name
ORDER BY 
    CASE p.status 
        WHEN 'active' THEN 1
        WHEN 'planning' THEN 2
        WHEN 'completed' THEN 3
        ELSE 4
    END,
    p.deadline ASC;

--Пример использования представления: найти проекты с низким процентом завершения
SELECT * FROM view_project_progress 
WHERE completion_percentage < 50 
AND project_status = 'active';



--Временные затраты по проектам
  --Фактические затраченные часы
  --Сравнение с оценкой (estimated vs actual)
  --Среднее время на запись
  --Количество уникальных сотрудников, работавших над проектом
  --Период работы над проектом (первая и последняя запись)

CREATE VIEW view_project_time_tracking AS
SELECT 
    p.id as project_id,
    p.name as project_name,
    p.status as project_status,
    t.name as team_name,
    COUNT(DISTINCT te.user_id) as unique_users_worked,
    COUNT(DISTINCT te.task_id) as tasks_with_time_entries,
    SUM(te.hours_spent) as total_hours_spent,
    ROUND(AVG(te.hours_spent), 2) as avg_hours_per_entry,
    SUM(tasks.estimated_hours) as total_estimated_hours,
    CASE 
        WHEN SUM(tasks.estimated_hours) > 0 
        THEN ROUND((SUM(te.hours_spent) * 100.0 / SUM(tasks.estimated_hours)), 2)
        ELSE 0 
    END as estimated_vs_actual_percent,
    MIN(te.entry_date) as first_time_entry,
    MAX(te.entry_date) as last_time_entry
FROM projects p
LEFT JOIN tasks ON tasks.project_id = p.id
LEFT JOIN time_entries te ON te.project_id = p.id
LEFT JOIN teams t ON p.team_id = t.id
GROUP BY 
    p.id, p.name, p.status, t.name
HAVING 
    SUM(te.hours_spent) > 0
ORDER BY 
    total_hours_spent DESC;

--Пример использования представления: найти проекты, где фактические затраты превышают оценку
SELECT * FROM view_project_time_tracking 
WHERE estimated_vs_actual_percent > 100;
