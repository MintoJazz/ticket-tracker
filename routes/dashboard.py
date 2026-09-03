from flask import Blueprint, jsonify, session
from psycopg2 import connect, sql
from psycopg2.extras import RealDictCursor

from config import DB_URL
from persistencias import DAO

bp = Blueprint('dashboard', __name__)

@bp.route('/') 
def dashboard():
    if 'workspace_id' not in session:
        return jsonify({"error": "workspace_id não definido na sessão. Selecione um workspace primeiro."}), 401

    workspace_id = session['workspace_id']
    payload = {}

    with connect(DB_URL) as connection:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            query = sql.SQL("SELECT * FROM get_dashboard(%s)")
            cursor.execute(query, (workspace_id,))

            payload['dashboard'] = cursor.fetchall()

        worklogDAO = DAO('worklogs')
        payload['worklogs'] = worklogDAO.select_all(connection=connection)

    return jsonify(payload)