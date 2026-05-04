from flask import Blueprint, jsonify
from psycopg2 import connect, sql
from psycopg2.extras import RealDictCursor

from config import DB_URL
from persistencias import DAO

bp = Blueprint('dashboard', __name__)

@bp.route('/') 
def dashboard():
    payload = {}

    with connect(DB_URL) as connection:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            query = sql.SQL("SELECT * FROM get_dashboard()")
            cursor.execute(query)

            payload['dashboard'] = cursor.fetchall()

        worklogDAO = DAO('worklogs')
        payload['worklogs'] = worklogDAO.select_all(connection=connection)

    return jsonify(payload)