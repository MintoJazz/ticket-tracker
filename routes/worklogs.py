from flask import Blueprint, jsonify
from use_cases.get_worklog_form_data import get_worklog_form_data
from use_cases.create_worklog import create_worklog
from use_cases.close_worklog import close_worklog
from middlewares import jsonify_result, validate_payload

bp = Blueprint('worklogs', __name__)

@bp.route('/<int:ticket_id>/novo', methods=['GET'])
@jsonify_result
def exibir_form(ticket_id):
    return get_worklog_form_data(ticket_id)

@bp.route('/<int:ticket_id>/novo', methods=['POST'])
@validate_payload('user_id', 'mensagem')
@jsonify_result
def processar_form(ticket_id, user_id, mensagem):
    return create_worklog(ticket_id, user_id, mensagem)

@bp.route('/<int:log_id>/encerrar', methods=['POST'])
@jsonify_result
def encerrar(log_id):
    return close_worklog(log_id)