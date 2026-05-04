CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER REFERENCES users(id),
    workspace_id INTEGER REFERENCES workspaces(id),
    title VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status status_registry DEFAULT 'AGUARDANDO ATENDIMENTO'
);