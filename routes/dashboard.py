from flask import Blueprint, render_template, redirect, url_for, session
from psycopg2 import connect, sql
from psycopg2.extras import RealDictCursor
from config import DB_URL

bp = Blueprint('dashboard', __name__)

@bp.route('/')
def dashboard():
    if 'workspace_id' not in session:
        return redirect(url_for('workspaces.selecionar'))

    workspace_id = session['workspace_id']

    with connect(DB_URL) as connection:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(sql.SQL("SELECT * FROM get_dashboard(%s)"), (workspace_id,))
            dados_dashboard = cursor.fetchone()
    
    return render_template('dashboard.html', dashboard=dados_dashboard)