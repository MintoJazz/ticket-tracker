from flask import Blueprint, jsonify, request
from use_cases.get_worklog_form_data import get_worklog_form_data
from use_cases.create_worklog import create_worklog
from use_cases.close_worklog import close_worklog

bp = Blueprint('worklogs', __name__)

@bp.route('/<int:ticket_id>/novo', methods=['GET'])
def exibir_form(ticket_id):
    result = get_worklog_form_data(ticket_id)
    if not result.is_success:
        return jsonify({"error": result.error}), result.status_code
        
    return jsonify(result.value), result.status_code

@bp.route('/<int:ticket_id>/novo', methods=['POST'])
def processar_form(ticket_id):
    data = request.get_json() or request.form
    user_id = data.get('user_id')
    mensagem = data.get('mensagem')
    
    result = create_worklog(ticket_id, user_id, mensagem)
    if not result.is_success:
        return jsonify({"error": result.error}), result.status_code
        
    return jsonify(result.value), result.status_code

@bp.route('/<int:log_id>/encerrar', methods=['POST'])
def encerrar(log_id):
    result = close_worklog(log_id)
    if not result.is_success:
        return jsonify({"error": result.error}), result.status_code
        
    return jsonify(result.value), result.status_code