# Project_Management_For_Small_Teams
Система управления проектами для малых команд

Описание проекта
База данных для системы управления проектами, командами и задачами в компании. Система позволяет отслеживать прогресс проектов, распределять задачи между сотрудниками, контролировать сроки и анализировать рабочую нагрузку.

Структура базы данных
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

Создание базы данных
>CREATE DATABASE Project_Management_For_Small_Teams;

Инициализация схемы
>Выполните SQL-скрипт создания таблиц из файла create_tables.sql

Наполнение тестовыми данными
>Выполните SQL-скрипт с INSERT-запросами для заполнения тестовыми данными из файла insert_data.sql

Ключевые представления
