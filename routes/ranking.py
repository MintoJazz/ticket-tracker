from flask import Blueprint, jsonify
from use_cases.get_ranking import get_ranking
from middlewares import require_workspace, jsonify_result

bp = Blueprint('ranking', __name__)

@bp.route('/ranking')
@require_workspace
@jsonify_result
def ranking(workspace_id):
    return get_ranking(workspace_id)