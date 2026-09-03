from flask import Blueprint, jsonify, session
from use_cases.list_workspaces import list_workspaces
from middlewares import jsonify_result, validate_payload

bp = Blueprint('workspaces', __name__, url_prefix='/workspaces')

@bp.route('/selecionar', methods=['GET'])
@jsonify_result
def selecionar():
    return list_workspaces()

@bp.route('/selecionar', methods=['POST'])
@validate_payload('workspace_id')
def selecionar_post(workspace_id):
    session['workspace_id'] = int(workspace_id)
    return jsonify({"message": "Workspace selecionado com sucesso!", "workspace_id": int(workspace_id)}), 200
