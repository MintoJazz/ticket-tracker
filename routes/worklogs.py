# routes/worklogs.py
import psycopg2
from flask import Blueprint, jsonify, request
from psycopg2 import connect
from psycopg2.extras import RealDictCursor
from config import DB_URL
from persistencias import DAO

bp = Blueprint('worklogs', __name__)

@bp.route('/<int:ticket_id>/novo', methods=['GET'])
def exibir_form(ticket_id):
    with connect(DB_URL) as connection:
        ticketDAO = DAO('tickets')
        ticket = ticketDAO.select_by_key(connection, 'id', ticket_id)
        if not ticket:
            return jsonify({"error": "Ticket não encontrado."}), 404

        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("""
                SELECT u.id, u.name 
                FROM users u
                JOIN workspace_users wu ON u.id = wu.user_id
                WHERE wu.workspace_id = %s AND wu.role = 'TECNICO'
                ORDER BY u.name
            """, (ticket['workspace_id'],))
            tecnicos = cursor.fetchall()

    return jsonify({"ticket_id": ticket_id, "tecnicos": tecnicos})

@bp.route('/<int:ticket_id>/novo', methods=['POST'])
def processar_form(ticket_id):
    data = request.get_json() or request.form
    user_id = data.get('user_id')
    mensagem = data.get('mensagem')
    
    try:
        with connect(DB_URL) as connection:
            worklogDAO = DAO('worklogs')
            worklogDAO.insert(connection, ticket_id=ticket_id, user_id=user_id, message=mensagem)
            connection.commit()
            
        return jsonify({"message": "Worklog registrado com sucesso!"}), 201
        
    except psycopg2.errors.RaiseException as e:
        msg_erro = str(e).split('\n')[0]
        return jsonify({"error": msg_erro}), 400
        
    except Exception: 
        return jsonify({"error": "Erro interno ao salvar o registro."}), 500

@bp.route('/<int:log_id>/encerrar', methods=['POST'])
def encerrar(log_id):
    try:
        with connect(DB_URL) as connection:
            with connection.cursor() as cursor:
                 cursor.execute("UPDATE worklogs SET ended_at = CURRENT_TIMESTAMP WHERE id = %s", (log_id,))
            connection.commit()
        return jsonify({"message": "Atendimento encerrado com sucesso!"}), 200
    except Exception:
        return jsonify({"error": "Erro ao encerrar atendimento."}), 500