--> Ranking de técnicos por tipo de chamado
CREATE OR REPLACE FUNCTION get_ranking_tecnicos() RETURNS TABLE(
    name VARCHAR,
    worklogs_count BIGINT
) AS $$
    SELECT u.name, COALESCE(t.count, 0) as worklogs_count 
    FROM users u 
    LEFT JOIN (
        SELECT user_id, COUNT(DISTINCT ticket_id) as count  
        FROM worklogs  
        GROUP BY user_id
    ) t ON u.id = t.user_id 
    WHERE u.id IN (SELECT user_id FROM workspace_users WHERE role = 'TECNICO')
    ORDER BY worklogs_count DESC;
$$ LANGUAGE sql;