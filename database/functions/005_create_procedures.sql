--> Procedure para reabrir serviço
CREATE OR REPLACE PROCEDURE reopen_ticket(p_ticket_id INT) AS $$ 
BEGIN
    UPDATE tickets SET status = 'SERVIÇO REABERTO' WHERE id = p_ticket_id;
END; 
$$ LANGUAGE plpgsql;

--> Procedure para registrar worklog
CREATE OR REPLACE PROCEDURE set_worklog(p_ticket_id INT, p_user_id INT, p_message TEXT) AS $$ 
BEGIN
    INSERT INTO worklogs (ticket_id, user_id, message) 
    VALUES (p_ticket_id, p_user_id, p_message);
    
    IF p_message ILIKE '%resolvido%' THEN 
        UPDATE tickets SET status = 'FINALIZADO' WHERE id = p_ticket_id;
    END IF;
END; 
$$ LANGUAGE plpgsql;