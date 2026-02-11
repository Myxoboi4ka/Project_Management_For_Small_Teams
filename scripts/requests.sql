--Рейтинг задач по времени выполнения в каждом проекте:
	--Показывает, какие задачи в каждом проекте выходят за рамки оценок времени
	--Помогает выявить систематические ошибки в оценке
	--Позволяет сравнивать отклонения внутри одного проекта
	--Указывает на проблемы в планировании конкретных типов задач

SELECT 
    p.name as project_name,
    t.title,
    t.estimated_hours,
    t.actual_hours,
    ROUND(t.actual_hours / NULLIF(t.estimated_hours, 0), 2) as time_variance,
    RANK() OVER (PARTITION BY t.project_id ORDER BY (t.actual_hours / NULLIF(t.estimated_hours, 0)) DESC) as variance_rank_in_project,
    AVG(t.actual_hours / NULLIF(t.estimated_hours, 0)) OVER (PARTITION BY t.project_id) as avg_variance_in_project
FROM tasks t
JOIN projects p ON t.project_id = p.id
WHERE t.estimated_hours > 0 
    AND t.actual_hours IS NOT NULL
    AND t.actual_hours > 0
ORDER BY p.name, variance_rank_in_project;


--Анализ загрузки сотрудников с подсчетом вложенных сущностей
  --Дает полную картину активности каждого сотрудника
  --Показывает баланс между назначенными и выполненными задачами
  --Отражает вовлеченность через комментарии
  --Помогает выявить перегруженных или недогруженных сотрудников

SELECT 
    u.full_name,
    u.role,
    (SELECT COUNT(*) FROM tasks WHERE assignee_id = u.id) as assigned_tasks,
    (SELECT COUNT(*) FROM tasks WHERE assignee_id = u.id AND status = 'completed') as completed_tasks,
    (SELECT COUNT(*) FROM task_comments WHERE user_id = u.id) as total_comments,
    (SELECT COUNT(*) FROM time_entries WHERE user_id = u.id) as time_entries_count,
    (SELECT SUM(hours_spent) FROM time_entries WHERE user_id = u.id) as total_hours_spent,
    ROUND(
        (SELECT COUNT(*) FROM tasks WHERE assignee_id = u.id AND status = 'completed') * 100.0 / 
        NULLIF((SELECT COUNT(*) FROM tasks WHERE assignee_id = u.id), 0), 
        2
    ) as completion_rate
FROM users u
WHERE u.is_active = true
ORDER BY total_hours_spent DESC;


--Поиск проблемных проектов
  --Автоматически выявляет проблемные проекты по критериям
  --Показывает проекты с множеством просроченных задач
  --Находит проекты с низким процентом завершения
  --Помогает расставить приоритеты для менеджерского вмешательства

SELECT 
    p.id,
    p.name,
    p.status,
    COUNT(t.id) as total_tasks,
    COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as completed_tasks,
    COUNT(CASE WHEN t.due_date < CURRENT_DATE AND t.status != 'completed' THEN 1 END) as overdue_tasks,
    AVG(t.due_date - CURRENT_DATE) as avg_days_to_deadline,
    COUNT(DISTINCT t.assignee_id) as unique_assignees,
    COUNT(tc.id) as total_comments,
    ROUND(COUNT(CASE WHEN t.status = 'completed' THEN 1 END) * 100.0 / COUNT(t.id), 2) as completion_percentage
FROM projects p
LEFT JOIN tasks t ON p.id = t.project_id
LEFT JOIN task_comments tc ON t.id = tc.task_id
WHERE p.status = 'active'
GROUP BY p.id, p.name, p.status
HAVING 
    COUNT(CASE WHEN t.due_date < CURRENT_DATE AND t.status != 'completed' THEN 1 END) > 3
    OR ROUND(COUNT(CASE WHEN t.status = 'completed' THEN 1 END) * 100.0 / COUNT(t.id), 2) < 30
ORDER BY overdue_tasks DESC, completion_percentage ASC;


--Анализ связи между задачами, подзадачами и временем
  --Анализирует связь между декомпозицией задач (подзадачи) и затраченным временем
  --Показывает, сколько людей работало над каждой задачей
  --Выявляет задачи с большой детализацией (много подзадач)
  --Помогает оптимизировать процесс декомпозиции задач

SELECT 
    t.id as task_id,
    t.title as task_title,
    t.status as task_status,
    COUNT(st.id) as subtask_count,
    COUNT(CASE WHEN st.is_completed = true THEN 1 END) as completed_subtasks,
    COUNT(te.id) as time_entries_count,
    SUM(te.hours_spent) as total_hours_spent,
    AVG(te.hours_spent) as avg_hours_per_entry,
    COUNT(DISTINCT te.user_id) as unique_users_logged_time,
    STRING_AGG(DISTINCT u.full_name, ', ') as users_involved
FROM tasks t
LEFT JOIN subtasks st ON t.id = st.task_id
LEFT JOIN time_entries te ON t.id = te.task_id
LEFT JOIN users u ON te.user_id = u.id
WHERE t.status IN ('in_progress', 'completed')
GROUP BY t.id, t.title, t.status
HAVING COUNT(st.id) > 0 AND COUNT(te.id) > 0
ORDER BY subtask_count DESC, total_hours_spent DESC;


--Обзор просроченных задач для ежедневных встреч
  --Автоматическая приоритезация по важности задач
  --Четкое распределение ответственности
  --Наглядная визуализация срочности и контекст
  --Выявление системных проблем в планировании и оценке

SELECT 
    u.full_name as "Исполнитель",
    t.title as "Задача",
    p.name as "Проект",
    t.priority as "Приоритет",
    t.due_date as "Дедлайн",
    (CURRENT_DATE - t.due_date) as "Дней просрочки",
    CASE 
        WHEN t.priority = 'high' THEN '🔴 '
        WHEN t.priority = 'medium' THEN '🟡 '
        WHEN t.priority = 'low' THEN '🟢 '
        ELSE ''
    END || t.title as "Задача с иконкой"
FROM tasks t
JOIN projects p ON t.project_id = p.id
JOIN users u ON t.assignee_id = u.id
WHERE t.due_date < CURRENT_DATE 
    AND t.status NOT IN ('completed', 'cancelled')
    AND p.status = 'active'
ORDER BY 
    CASE t.priority 
        WHEN 'high' THEN 1
        WHEN 'medium' THEN 2
        WHEN 'low' THEN 3
        ELSE 4
    END,
    t.due_date,
    u.full_name;
