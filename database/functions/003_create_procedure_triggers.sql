--> Trigger com Regras de Negócio Avançadas - Regra de Concorrência de Worklog
DROP TRIGGER IF EXISTS trg_block_concurrent_worklog ON worklogs;
CREATE TRIGGER trg_block_concurrent_worklog
BEFORE INSERT ON worklogs
FOR EACH ROW EXECUTE FUNCTION block_concurrent_worklogs();

--> Trigger de Auditoria - Tickets
DROP TRIGGER IF EXISTS trg_audit_tickets ON tickets;
CREATE TRIGGER trg_audit_tickets
AFTER INSERT OR UPDATE OR DELETE ON tickets
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

--> Trigger de Auditoria - WorkLogs
DROP TRIGGER IF EXISTS trg_audit_worklogs ON worklogs;
CREATE TRIGGER trg_audit_worklogs
AFTER INSERT OR UPDATE OR DELETE ON worklogs
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

--> Trigger de Automatização de Serviços - Máquina de Estados para Status de Tickets
DROP TRIGGER IF EXISTS trg_automate_ticket_status ON worklogs;
CREATE TRIGGER trg_automate_ticket_status
AFTER INSERT ON worklogs
FOR EACH ROW EXECUTE FUNCTION automate_ticket_status();