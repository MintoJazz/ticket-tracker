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