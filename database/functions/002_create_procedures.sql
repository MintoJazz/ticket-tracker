--> Procedure para reabrir serviço
CREATE OR REPLACE PROCEDURE reopen_ticket(p_ticket_id INT) AS $$ 
BEGIN
    UPDATE tickets SET status = 'SERVIÇO REABERTO' WHERE id = p_ticket_id;
END; 
$$ LANGUAGE plpgsql;
