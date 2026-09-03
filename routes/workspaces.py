# routes/workspaces.py
from flask import Blueprint, jsonify, request, session
from psycopg2 import connect
from config import DB_URL
from persistencias import DAO

bp = Blueprint('workspaces', __name__, url_prefix='/workspaces')

@bp.route('/selecionar', methods=['GET'])
def selecionar():
    with connect(DB_URL) as connection:
        workspaceDAO = DAO('workspaces')
        workspaces = workspaceDAO.select_all(connection)

    return jsonify({"workspaces": workspaces})

@bp.route('/selecionar', methods=['POST'])
def selecionar_post():
    data = request.get_json() or request.form
    workspace_id = data.get('workspace_id')
    
    if not workspace_id:
        return jsonify({"error": "workspace_id é obrigatório."}), 400

    session['workspace_id'] = int(workspace_id)
    return jsonify({"message": "Workspace selecionado com sucesso!", "workspace_id": int(workspace_id)}), 200
