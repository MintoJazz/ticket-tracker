# routes/worklogs.py
import psycopg2
from flask import Blueprint, render_template, request, redirect, url_for, flash
from psycopg2 import connect
from psycopg2.extras import RealDictCursor
from config import DB_URL
from persistencias import DAO

bp = Blueprint('worklogs', __name__)

@bp.route('/<int:ticket_id>/novo', methods=['GET'])
def exibir_form(ticket_id):
    with connect(DB_URL) as connection:
        ticketDAO = DAO('tickets')
        ticket = ticketDAO.select_by_key(connection, 'id', ticket_id)
        if not ticket:
            flash("Ticket não encontrado.", "error")
            return redirect(url_for('tickets.lista_servicos'))

        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("""
                SELECT u.id, u.name 
                FROM users u
                JOIN workspace_users wu ON u.id = wu.user_id
                WHERE wu.workspace_id = %s AND wu.role = 'TECNICO'
                ORDER BY u.name
            """, (ticket['workspace_id'],))
            tecnicos = cursor.fetchall()

    return render_template('worklog-form.html', ticket_id=ticket_id, tecnicos=tecnicos)

@bp.route('/<int:ticket_id>/novo', methods=['POST'])
def processar_form(ticket_id):
    user_id = request.form.get('user_id')
    mensagem = request.form.get('mensagem')
    
    try:
        with connect(DB_URL) as connection:
            worklogDAO = DAO('worklogs')
            worklogDAO.insert(connection, ticket_id=ticket_id, user_id=user_id, message=mensagem)
            connection.commit()
            
        flash("Worklog registrado com sucesso!", "success")
        return redirect(url_for('tickets.perfil_servico', ticket_id=ticket_id))
        
    except psycopg2.errors.RaiseException as e:
        msg_erro = str(e).split('\n')[0]
        flash(msg_erro, "error")
        return redirect(url_for('worklogs.exibir_form', ticket_id=ticket_id))
        
    except Exception: 
        flash("Erro interno ao salvar o registro.", "error")
        return redirect(url_for('worklogs.exibir_form', ticket_id=ticket_id))

@bp.route('/<int:log_id>/encerrar', methods=['POST'])
def encerrar(log_id):
    ticket_id = request.form.get('ticket_id')
    try:
        with connect(DB_URL) as connection:
            with connection.cursor() as cursor:
                 cursor.execute("UPDATE worklogs SET ended_at = CURRENT_TIMESTAMP WHERE id = %s", (log_id,))
            connection.commit()
        flash("Atendimento encerrado com sucesso!", "success")
    except Exception:
        flash("Erro ao encerrar atendimento.", "error")
        
    return redirect(url_for('tickets.perfil_servico', ticket_id=ticket_id))