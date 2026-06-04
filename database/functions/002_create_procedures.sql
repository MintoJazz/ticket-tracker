--> Procedure para reabrir serviço
CREATE OR REPLACE PROCEDURE reopen_ticket(p_ticket_id INT) AS $$ 
BEGIN
    UPDATE tickets SET status = 'SERVIÇO REABERTO' WHERE id = p_ticket_id;
END; 
$$ LANGUAGE plpgsql;

--> Procedure do Trigger de Auditoria
CREATE OR REPLACE FUNCTION audit_trigger_func() RETURNS trigger AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_logs (table_name, operation, record_data)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD));
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_logs (table_name, operation, record_data)
        VALUES (TG_TABLE_NAME, TG_OP, jsonb_build_object('before', row_to_json(OLD), 'after', row_to_json(NEW)));
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_logs (table_name, operation, record_data)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(NEW));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

--> Trigger de Automatização de Serviços - Máquina de Estados para Status de Tickets
CREATE OR REPLACE FUNCTION automate_ticket_status() RETURNS trigger AS $$
DECLARE
    current_status status_registry;
BEGIN
    SELECT status INTO current_status FROM tickets WHERE id = NEW.ticket_id;

    IF NEW.message ILIKE '%resolvido%' THEN
        UPDATE tickets SET status = 'FINALIZADO' WHERE id = NEW.ticket_id;
        
    ELSIF current_status IN ('FINALIZADO', 'CANCELADO') THEN
        CALL reopen_ticket(NEW.ticket_id);

    ELSIF current_status = 'AGUARDANDO ATENDIMENTO' THEN
        UPDATE tickets SET status = 'EM ATENDIMENTO' WHERE id = NEW.ticket_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
