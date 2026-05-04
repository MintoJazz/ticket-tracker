from flask import Blueprint, jsonify
from psycopg2 import connect, sql
from psycopg2.extras import RealDictCursor

from config import DB_URL

bp = Blueprint('ranking', __name__)

@bp.route('/ranking')
def ranking():
    payload = {}

    with connect(DB_URL) as connection:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            query = sql.SQL("SELECT * FROM get_ranking_tecnicos()")
            cursor.execute(query)

            payload['ranking'] = cursor.fetchall()
        
    return jsonify(payload)