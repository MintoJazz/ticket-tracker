from psycopg2 import connect
from config import DB_URL
from utils.result import Result

def close_worklog(log_id):
    try:
        with connect(DB_URL) as connection:
            with connection.cursor() as cursor:
                 cursor.execute("UPDATE worklogs SET ended_at = CURRENT_TIMESTAMP WHERE id = %s", (log_id,))
            connection.commit()
        return Result.success({"message": "Atendimento encerrado com sucesso!"}, 200)
    except Exception as e:
        return Result.failure(f"Erro ao encerrar atendimento: {str(e)}", 500)
