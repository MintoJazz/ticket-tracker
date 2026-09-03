from psycopg2 import connect
from psycopg2.extras import RealDictCursor
from config import DB_URL
from utils.result import Result
from utils.persistencias import DAO

def get_worklog_form_data(ticket_id):
    try:
        with connect(DB_URL) as connection:
            ticketDAO = DAO('tickets')
            ticket = ticketDAO.select_by_key(connection, 'id', ticket_id)
            if not ticket:
                return Result.failure("Ticket não encontrado.", 404)

            with connection.cursor(cursor_factory=RealDictCursor) as cursor:
                cursor.execute("""
                    SELECT u.id, u.name 
                    FROM users u
                    JOIN workspace_users wu ON u.id = wu.user_id
                    WHERE wu.workspace_id = %s AND wu.role = 'TECNICO'
                    ORDER BY u.name
                """, (ticket['workspace_id'],))
                tecnicos = cursor.fetchall()

        return Result.success({"ticket_id": ticket_id, "tecnicos": tecnicos})
    except Exception as e:
        return Result.failure(f"Erro interno: {str(e)}", 500)
