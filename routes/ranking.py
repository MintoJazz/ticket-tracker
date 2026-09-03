from flask import Blueprint, jsonify, session
from psycopg2 import connect, sql
from psycopg2.extras import RealDictCursor

from config import DB_URL

bp = Blueprint('ranking', __name__)

@bp.route('/ranking')
def ranking():
    if 'workspace_id' not in session:
        return jsonify({"error": "workspace_id não definido na sessão. Selecione um workspace primeiro."}), 401

    workspace_id = session['workspace_id']
    payload = {}

    with connect(DB_URL) as connection:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            query = sql.SQL("SELECT * FROM get_ranking_tecnicos(%s)")
            cursor.execute(query, (workspace_id,))

            payload['ranking'] = cursor.fetchall()
        
    return jsonify(payload)