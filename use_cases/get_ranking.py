from psycopg2 import connect, sql
from psycopg2.extras import RealDictCursor
from config import DB_URL
from utils.result import Result

def get_ranking(workspace_id):
    try:
        with connect(DB_URL) as connection:
            with connection.cursor(cursor_factory=RealDictCursor) as cursor:
                query = sql.SQL("SELECT * FROM get_ranking_tecnicos()")
                cursor.execute(query)
                ranking = cursor.fetchall()
        
        return Result.success({"ranking": ranking})
    except Exception as e:
        return Result.failure(f"Erro interno: {str(e)}", 500)
