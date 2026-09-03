from flask import Blueprint, jsonify, session
from use_cases.get_dashboard_data import get_dashboard_data

bp = Blueprint('dashboard', __name__)

@bp.route('/') 
def dashboard():
    if 'workspace_id' not in session:
        return jsonify({"error": "workspace_id não definido na sessão. Selecione um workspace primeiro."}), 401

    workspace_id = session['workspace_id']
    
    result = get_dashboard_data(workspace_id)
    if not result.is_success:
        return jsonify({"error": result.error}), result.status_code
        
    return jsonify(result.value), result.status_code