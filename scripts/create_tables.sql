CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    role VARCHAR(50) DEFAULT 'member',
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    owner_id INT REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE team_members (
    id SERIAL PRIMARY KEY,
    team_id INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'member',
    UNIQUE(team_id, user_id)
);

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    team_id INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    manager_id INT REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'active',
    start_date DATE,
    deadline DATE
);

CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    project_id INT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'todo',
    priority VARCHAR(20) DEFAULT 'medium',
    assignee_id INT REFERENCES users(id) ON DELETE SET NULL,
    reporter_id INT REFERENCES users(id) ON DELETE SET NULL,
    estimated_hours DECIMAL(5,2),
    actual_hours DECIMAL(5,2),
    due_date DATE
);

CREATE TABLE subtasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    task_id INT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    is_completed BOOLEAN DEFAULT false,
    assignee_id INT REFERENCES users(id) ON DELETE SET NULL,
    due_date DATE
);

CREATE TABLE task_comments (
    id SERIAL PRIMARY KEY,
    task_id INT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    attachment_url TEXT
);

CREATE TABLE progress_reports (
    id SERIAL PRIMARY KEY,
    project_id INT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    author_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    content TEXT NOT NULL,
    blockers TEXT,
    next_week_plan TEXT
);

CREATE TABLE time_entries (
    id SERIAL PRIMARY KEY,
    task_id INT REFERENCES tasks(id) ON DELETE SET NULL,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    project_id INT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    description TEXT,
    hours_spent DECIMAL(4,2) NOT NULL,
    entry_date DATE NOT NULL
);

CREATE TABLE attachments (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(500) NOT NULL,
    file_url TEXT NOT NULL,
    file_size INT,
    mime_type VARCHAR(100),
    task_id INT REFERENCES tasks(id) ON DELETE CASCADE,
    comment_id INT REFERENCES task_comments(id) ON DELETE CASCADE,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    uploaded_by INT NOT NULL REFERENCES users(id) ON DELETE CASCADE
);

