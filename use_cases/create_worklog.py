import psycopg2
from psycopg2 import connect
from config import DB_URL
from utils.result import Result
from utils.persistencias import DAO

def create_worklog(ticket_id, user_id, mensagem):
    try:
        with connect(DB_URL) as connection:
            worklogDAO = DAO('worklogs')
            worklogDAO.insert(connection, ticket_id=ticket_id, user_id=user_id, message=mensagem)
            connection.commit()
            
        return Result.success({"message": "Worklog registrado com sucesso!"}, 201)
        
    except psycopg2.errors.RaiseException as e:
        msg_erro = str(e).split('\n')[0]
        return Result.failure(msg_erro, 400)
        
    except Exception as e:
        return Result.failure(f"Erro interno ao salvar o registro: {str(e)}", 500)
