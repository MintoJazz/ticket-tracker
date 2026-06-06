# routes/workspaces.py
from flask import Blueprint, render_template, request, redirect, url_for, session
from psycopg2 import connect
from config import DB_URL
from persistencias import DAO

bp = Blueprint('workspaces', __name__, url_prefix='/workspaces')

@bp.route('/selecionar', methods=['GET'])
def selecionar():
    with connect(DB_URL) as connection:
        workspaceDAO = DAO('workspaces')
        workspaces = workspaceDAO.select_all(connection)

    return render_template('workspace-select.html', workspaces=workspaces)

@bp.route('/selecionar', methods=['POST'])
def selecionar_post():
    workspace_id = request.form.get('workspace_id')
    session['workspace_id'] = int(workspace_id)
    return redirect(url_for('dashboard.dashboard'))
