from flask import Blueprint, jsonify, session
from use_cases.list_workspace_tickets import list_workspace_tickets
from use_cases.get_ticket_details import get_ticket_details

bp = Blueprint('tickets', __name__)

@bp.route('/')
def lista_servicos():
    if 'workspace_id' not in session:
        return jsonify({"error": "workspace_id não definido na sessão. Selecione um workspace primeiro."}), 401

    result = list_workspace_tickets(session['workspace_id'])
    if not result.is_success:
        return jsonify({"error": result.error}), result.status_code
        
    return jsonify(result.value), result.status_code

@bp.route('/<int:ticket_id>')
def perfil_servico(ticket_id):
    result = get_ticket_details(ticket_id)
    if not result.is_success:
        return jsonify({"error": result.error}), result.status_code
        
    return jsonify(result.value), result.status_code