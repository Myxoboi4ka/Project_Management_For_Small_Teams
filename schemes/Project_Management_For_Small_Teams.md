ER-диаграмма и описание структуры базы данных включены в репозиторий.

Table public.users
Пользователи системы 

|Поле|Тип данных|Описание|Ограничения|
|----|----------|--------|-----------|
|id|SERIAL|Уникальный идентификатор пользователя|PRIMARY KEY|
|email|VARCHAR(255)|Email пользователя|UNIQUE, NOT NULL|
|username|VARCHAR(100)|Имя пользователя|UNIQUE, NOT NULL|
|full_name|VARCHAR(255)|Полное имя пользователя|NOT NULL|
|password_hash|VARCHAR(255)|Хеш пароля|NOT NULL|
|avatar_url|TEXT|URL аватара||
|role|VARCHAR(50)|Роль пользователя|DEFAULT 'member'|
|is_active|BOOLEAN|Статус активности|DEFAULT true|


Table public.teams
Команды пользователей

|Поле|Тип данных|Описание|Ограничения|
|----|----------|--------|-----------|
|id|SERIAL|Уникальный идентификатор команды|PRIMARY KEY|
|name|VARCHAR(255)|Название команды|NOT NULL|
|description|TEXT|Описание команды||
|owner_id|INT|ID владельца команды|FOREIGN KEY REFERENCES users(id) ON DELETE SET NULL|


Table public.team_members
Участники команд

|Поле|Тип данных|Описание|Ограничения|
|----|----------|--------|-----------|
|id|SERIAL|Уникальный идентификатор записи|PRIMARY KEY|
|team_id|INT|ID команды|FOREIGN KEY REFERENCES teams(id) ON DELETE CASCADE, NOT NULL|
|user_id|INT|ID пользователя|FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE, NOT NULL|
|role|VARCHAR(50)|Роль в команде|DEFAULT 'member'|


Table public.projects
Проекты команд

|Поле|Тип данных|Описание|Ограничения|
|----|----------|--------|-----------|
|id|SERIAL|Уникальный идентификатор проекта|PRIMARY KEY|
|name|VARCHAR(255)|Название проекта|NOT NULL|
|description|TEXT|Описание проекта||
|team_id|INT|ID команды|FOREIGN KEY REFERENCES teams(id) ON DELETE CASCADE, NOT NULL|
|manager_id|INT|ID менеджера проекта|	FOREIGN KEY REFERENCES users(id) ON DELETE SET NULL|
|status|VARCHAR(50)|Статус проекта|DEFAULT 'active'|
|start_date|DATE|Дата начала проекта||
|deadline|DATE|Дедлайн проекта||


Table public.tasks
Задачи проекта

|Поле|Тип данных|Описание|Ограничения|
|----|----------|--------|-----------|
|id|SERIAL|Уникальный идентификатор задачи|PRIMARY KEY|
|title|VARCHAR(500)|Заголовок задачи|NOT NULL|
|description|TEXT|Описание задачи||
|project_id|INT|ID проекта|FOREIGN KEY REFERENCES projects(id) ON DELETE CASCADE, NOT NULL|
|status|VARCHAR(50)|Статус задачи|DEFAULT 'todo'|
|priority|VARCHAR(50)|Приоритет задачи|DEFAULT 'medium'|
|assignee_id|INT|ID исполнителя|FOREIGN KEY REFERENCES users(id) ON DELETE SET NULL|
|reporter_id|INT|ID автора задачи|FOREIGN KEY REFERENCES users(id) ON DELETE SET NULL|
|estimated_hours|DECIMAL(5,2)|Плановое время выполнения||
|actual_hours|DECIMAL(5,2)|Фактическое время выполнения||
|due_date|DATE|Срок выполнения задачи||


Table public.subtasks
Подзадачи

|Поле|Тип данных|Описание|Ограничения|
|----|----------|--------|-----------|
|id|SERIAL|Уникальный идентификатор подзадачи|PRIMARY KEY|
|title|VARCHAR(500)|Заголовок подзадачи|NOT NULL|
|task_id|INT|ID родительской задачи|FOREIGN KEY REFERENCES tasks(id) ON DELETE CASCADE, NOT NULL|
|is_completed|BOOLEAN|Статус выполнения|DEFAULT false|
|assignee_id|INT|ID исполнителя|FOREIGN KEY REFERENCES users(id) ON DELETE SET NULL|
|due_date|DATE|Срок выполнения подзадачи||


Table public.task_comments
Комментарии к задачам

|Поле|Тип данных|Описание|Ограничения|
|----|----------|--------|-----------|
|id|SERIAL|Уникальный идентификатор комментария|PRIMARY KEY|
|task_id|INT|ID задачи|FOREIGN KEY REFERENCES tasks(id) ON DELETE CASCADE, NOT NULL|
|user_id|INT|ID автора комментария|FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE, NOT NULL|
|content|TEXT|Текст комментария|NOT NULL|
|attachment_url|TEXT|URL вложения||


Table public.progress_reports
Отчеты о прогрессе

|Поле|Тип данных|Описание|Ограничения|
|----|----------|--------|-----------|
|id|SERIAL|Уникальный идентификатор отчёта|PRIMARY KEY|
|project_id|INT|ID проекта|FOREIGN KEY REFERENCES projects(id) ON DELETE CASCADE, NOT NULL|
|author_id|INT|ID автора отчёта|FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE, NOT NULL|
|period_start|DATE|Начало отчётного периода|NOT NULL|
|period_end|DATE|Конец отчётного периода|NOT NULL|
|content|TEXT|Содержание отчёта|NOT NULL|
|blockers|TEXT|Блокирующие факторы||
|next_week_plan|TEXT|План на следующую неделю||


Table public.time_entries
Учет рабочего времени

|Поле|Тип данных|Описание|Ограничения|
|----|----------|--------|-----------|
|id|SERIAL|Уникальный идентификатор записи|PRIMARY KEY|
|task_id|INT|ID задачи|FOREIGN KEY REFERENCES tasks(id) ON DELETE SET NULL|
|user_id|INT|ID пользователя|FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE, NOT NULL|
|project_id|INT|ID проекта|FOREIGN KEY REFERENCES projects(id) ON DELETE CASCADE, NOT NULL|
|description|TEXT|Описание работы||
|hours_spent|DECIMAL(4,2)|Затраченное время|NOT NULL|
|entry_date|DATE|Дата учёта времени|NOT NULL|


Table public.attachments
Вложения файлов

|Поле|Тип данных|Описание|Ограничения|
|----|----------|--------|-----------|
|id|SERIAL|Уникальный идентификатор вложения|PRIMARY KEY|
|filename|VARCHAR(500)|Имя файла|NOT NULL|
|file_url|TEXT|URL файла|NOT NULL|
|file_size|INT|Размер файла||
|mime_type|VARCHAR(100)|MIME-тип файла||
|task_id|INT|ID задачи|FOREIGN KEY REFERENCES tasks(id) ON DELETE CASCADE|
|comment_id|INT|ID комментария|FOREIGN KEY REFERENCES task_comments(id) ON DELETE CASCADE|
|project_id|INT|ID проекта|FOREIGN KEY REFERENCES projects(id) ON DELETE CASCADE|
|uploaded_by|INT|ID загрузившего пользователя|FOREIGN KEY REFERENCES users(id) ON DELETE CASCADE, NOT NULL|


ER-диаграмма:
<img width="1784" height="884" alt="image" src="https://github.com/user-attachments/assets/50f003a2-bd3a-4aef-a752-5979827d6f7a" />
