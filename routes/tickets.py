from flask import Blueprint, jsonify, request
from psycopg2 import connect, sql
from psycopg2.extras import RealDictCursor

from config import DB_URL
from persistencias import DAO

bp = Blueprint('tickets', __name__)

@bp.route('/servico/<id>')
def get_prioridade(id):
    payload = {}
    with connect(DB_URL) as connection:
        ticketDAO = DAO('tickets')
        payload['ticket'] = ticketDAO.select_by_key(connection, 'id', id)

        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            query = sql.SQL("SELECT * FROM get_prioridade(%s)")
            cursor.execute(query, (id, ))

            payload['prioridade'] = cursor.fetchall()

    return jsonify(payload)
    
@bp.route("/status", methods=['POST'])
def set_status():
    data = request.get_json()
    if not data:
        return jsonify({"error": "Corpo da requisição deve ser um JSON válido."}), 400

    ticket_id = data.get('ticket_id')
    user_id = data.get('user_id')
    message = data.get('message')

    if not ticket_id or not user_id or not message:
        return jsonify({
            "error": "Os campos 'ticket_id', 'user_id' e 'message' são obrigatórios."
        }), 400

    try:
        with connect(DB_URL) as connection:
            with connection.cursor() as cursor:
                query = sql.SQL("CALL set_worklog(%s, %s, %s)")
                cursor.execute(query, (ticket_id, user_id, message))
            
            connection.commit()

        return jsonify({"message": "Worklog registrado com sucesso!"}), 201

    except Exception as e:
        return jsonify({"error": f"Erro interno do servidor: {str(e)}"}), 500