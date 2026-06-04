CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    table_name TEXT,
    operation TEXT,
    record_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);