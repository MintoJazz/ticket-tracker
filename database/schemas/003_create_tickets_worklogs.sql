CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER REFERENCES users(id),
    workspace_id INTEGER REFERENCES workspaces(id),
    title VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status status_registry DEFAULT 'AGUARDANDO ATENDIMENTO'
);

CREATE TABLE worklogs (
    id SERIAL PRIMARY KEY,
    ticket_id INTEGER REFERENCES tickets(id),
    user_id INTEGER REFERENCES users(id),
    begun_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    message TEXT
);