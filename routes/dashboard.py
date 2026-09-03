from flask import Blueprint, jsonify
from use_cases.get_dashboard_data import get_dashboard_data
from middlewares import require_workspace, jsonify_result

bp = Blueprint('dashboard', __name__)

@bp.route('/') 
@require_workspace
@jsonify_result
def dashboard(workspace_id):
    return get_dashboard_data(workspace_id)