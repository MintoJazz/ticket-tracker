from flask import Blueprint, jsonify
from use_cases.list_workspace_tickets import list_workspace_tickets
from use_cases.get_ticket_details import get_ticket_details
from middlewares import require_workspace, jsonify_result

bp = Blueprint('tickets', __name__)

@bp.route('/')
@require_workspace
@jsonify_result
def lista_servicos(workspace_id):
    return list_workspace_tickets(workspace_id)

@bp.route('/<int:ticket_id>')
@jsonify_result
def perfil_servico(ticket_id):
    return get_ticket_details(ticket_id)