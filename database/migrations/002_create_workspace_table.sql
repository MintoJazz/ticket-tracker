CREATE TABLE workspaces (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE workspace_users (
    workspace_id INTEGER REFERENCES workspaces(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role role_registry DEFAULT 'TECNICO',
    PRIMARY KEY (user_id, workspace_id)
);