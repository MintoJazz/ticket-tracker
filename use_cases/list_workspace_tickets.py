from psycopg2 import connect
from config import DB_URL
from utils.result import Result
from utils.persistencias import DAO

def list_workspace_tickets(workspace_id):
    try:
        with connect(DB_URL) as connection:
            ticketDAO = DAO('tickets')
            todos_tickets = ticketDAO.select_many_by_key(connection, 'workspace_id', workspace_id)
        
        return Result.success({"tickets": todos_tickets})
    except Exception as e:
        return Result.failure(f"Erro interno: {str(e)}", 500)
