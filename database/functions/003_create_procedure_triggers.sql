--> Trigger de Auditoria - Tickets
CREATE TRIGGER trg_audit_tickets
AFTER INSERT OR UPDATE OR DELETE ON tickets
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

--> Trigger de Auditoria - WorkLogs
CREATE TRIGGER trg_audit_worklogs
AFTER INSERT OR UPDATE OR DELETE ON worklogs
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();