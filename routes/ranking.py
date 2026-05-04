from flask import Blueprint, render_template
from psycopg2 import connect, sql
from psycopg2.extras import RealDictCursor
from config import DB_URL

bp = Blueprint('ranking', __name__)

@bp.route('/ranking')
def ranking():
    with connect(DB_URL) as connection:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(sql.SQL("SELECT * FROM get_ranking_tecnicos()"))
            lista_ranking = cursor.fetchall()
        
    return render_template('ranking.html', ranking=lista_ranking)