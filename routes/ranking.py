from flask import Blueprint, jsonify, session
from use_cases.get_ranking import get_ranking

bp = Blueprint('ranking', __name__)

@bp.route('/ranking')
def ranking():
    if 'workspace_id' not in session:
        return jsonify({"error": "workspace_id não definido na sessão. Selecione um workspace primeiro."}), 401

    workspace_id = session['workspace_id']
    
    result = get_ranking(workspace_id)
    if not result.is_success:
        return jsonify({"error": result.error}), result.status_code
        
    return jsonify(result.value), result.status_code