--> Função para calcular tempo de worklog
CREATE OR REPLACE FUNCTION get_worklog_time(p_begin TIMESTAMP, p_end TIMESTAMP) RETURNS NUMERIC AS $$
    SELECT (EXTRACT(EPOCH FROM (p_end - p_begin)) / 3600.0)::NUMERIC;
$$ LANGUAGE sql;