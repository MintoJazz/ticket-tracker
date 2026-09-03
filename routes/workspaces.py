from flask import Blueprint, jsonify, request, session
from use_cases.list_workspaces import list_workspaces

bp = Blueprint('workspaces', __name__, url_prefix='/workspaces')

@bp.route('/selecionar', methods=['GET'])
def selecionar():
    result = list_workspaces()
    if not result.is_success:
        return jsonify({"error": result.error}), result.status_code
        
    return jsonify(result.value), result.status_code

@bp.route('/selecionar', methods=['POST'])
def selecionar_post():
    data = request.get_json() or request.form
    workspace_id = data.get('workspace_id')
    
    if not workspace_id:
        return jsonify({"error": "workspace_id é obrigatório."}), 400

    session['workspace_id'] = int(workspace_id)
    return jsonify({"message": "Workspace selecionado com sucesso!", "workspace_id": int(workspace_id)}), 200
