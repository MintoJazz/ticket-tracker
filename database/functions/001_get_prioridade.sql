--> Função de prioridade do serviço
CREATE OR REPLACE FUNCTION get_prioridade(int) RETURNS varchar AS $$
    SELECT CASE
        WHEN count < 2 THEN 'Baixa'
        WHEN count < 4 THEN 'Média'
        WHEN count > 3 THEN 'Alta'
    END AS priority FROM (SELECT ticket_id, COUNT(*) FROM worklogs a GROUP BY ticket_id) p WHERE p.ticket_id = $1;
$$ LANGUAGE sql;