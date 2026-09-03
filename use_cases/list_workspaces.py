from psycopg2 import connect
from config import DB_URL
from utils.result import Result
from utils.persistencias import DAO

def list_workspaces():
    try:
        with connect(DB_URL) as connection:
            workspaceDAO = DAO('workspaces')
            workspaces = workspaceDAO.select_all(connection)
        
        return Result.success({"workspaces": workspaces})
    except Exception as e:
        return Result.failure(f"Erro interno: {str(e)}", 500)
