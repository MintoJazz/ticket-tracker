
--> Função de prioridade do serviço
CREATE OR REPLACE FUNCTION get_prioridade(int) RETURNS varchar AS $$
    SELECT CASE
        WHEN count < 2 THEN 'Baixa'
        WHEN count < 4 THEN 'Média'
        WHEN count > 3 THEN 'Alta'
    END AS priority FROM (SELECT ticket_id, COUNT(*) FROM worklogs a GROUP BY ticket_id) p WHERE p.ticket_id = $1;
$$ LANGUAGE sql;

--> Função para calcular tempo de worklog
CREATE OR REPLACE FUNCTION get_worklog_time(p_begin TIMESTAMP, p_end TIMESTAMP) RETURNS NUMERIC AS $$
    SELECT (EXTRACT(EPOCH FROM (p_end - p_begin)) / 3600.0)::NUMERIC;
$$ LANGUAGE sql;

--> Ranking de técnicos por tipo de chamado
CREATE OR REPLACE FUNCTION get_ranking_tecnicos() RETURNS TABLE(
    name VARCHAR,
    worklogs_count BIGINT,
    workspace_names TEXT
) AS $$
    SELECT u.name, COALESCE(t.count, 0) as worklogs_count,
        COALESCE(string_agg(DISTINCT ws.name, ', ' ORDER BY ws.name), '') as workspace_names
    FROM users u 
    LEFT JOIN (
        SELECT user_id, COUNT(DISTINCT ticket_id) as count  
        FROM worklogs  
        GROUP BY user_id
    ) t ON u.id = t.user_id 
    LEFT JOIN workspace_users wu ON u.id = wu.user_id
    LEFT JOIN workspaces ws ON wu.workspace_id = ws.id
    WHERE u.id IN (SELECT user_id FROM workspace_users WHERE role = 'TECNICO')
    GROUP BY u.id, u.name, t.count
    ORDER BY worklogs_count DESC;
$$ LANGUAGE sql;

--> Função do Dashboard
CREATE OR REPLACE FUNCTION get_dashboard() RETURNS TABLE (
    workspace_id INT,
    workspace_name VARCHAR,
    total_tickets BIGINT, 
    open_tickets BIGINT, 
    finished_tickets BIGINT, 
    avg_worklog_time_hours NUMERIC
) AS $$ 
BEGIN
    RETURN QUERY
    SELECT 
        ws.id AS workspace_id,
        ws.name AS workspace_name,
        COUNT(t.id)::BIGINT AS total_tickets,
        COUNT(t.id) FILTER (WHERE t.status NOT IN ('FINALIZADO', 'CANCELADO'))::BIGINT AS open_tickets,
        COUNT(t.id) FILTER (WHERE t.status = 'FINALIZADO')::BIGINT AS finished_tickets,
        COALESCE(ROUND(AVG(get_worklog_time(t.created_at, max_min.ended_at)), 2), 0)::NUMERIC AS avg_worklog_time_hours
    FROM workspaces ws
    LEFT JOIN tickets t ON ws.id = t.workspace_id
    LEFT JOIN (
        SELECT ticket_id, MAX(ended_at) AS ended_at 
        FROM worklogs 
        GROUP BY ticket_id
    ) max_min ON t.id = max_min.ticket_id
    GROUP BY ws.id, ws.name
    ORDER BY ws.id;
END; 
$$ LANGUAGE plpgsql;