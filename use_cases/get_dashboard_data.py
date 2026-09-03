from psycopg2 import connect, sql
from psycopg2.extras import RealDictCursor
from config import DB_URL
from utils.result import Result
from utils.persistencias import DAO

def get_dashboard_data(workspace_id):
    try:
        payload = {}
        with connect(DB_URL) as connection:
            with connection.cursor(cursor_factory=RealDictCursor) as cursor:
                query = sql.SQL("SELECT * FROM get_dashboard() WHERE workspace_id = %s")
                cursor.execute(query, (workspace_id,))
                payload['dashboard'] = cursor.fetchall()

            worklogDAO = DAO('worklogs')
            payload['worklogs'] = worklogDAO.select_all(connection=connection)

        return Result.success(payload)
    except Exception as e:
        return Result.failure(f"Erro interno: {str(e)}", 500)
