from flask import Blueprint, render_template, request, redirect, url_for
from psycopg2 import connect
from psycopg2.extras import RealDictCursor
from config import DB_URL
from persistencias import DAO

bp = Blueprint('tickets', __name__)

@bp.route('/servico/')
def lista_servicos():
    with connect(DB_URL) as connection:
        ticketDAO = DAO('tickets')
        todos_tickets = ticketDAO.select_all(connection)
        
    return render_template('ticket-list.html', tickets=todos_tickets)

@bp.route('/servico/<int:id>')
def perfil_servico(id):
    with connect(DB_URL) as connection:
        ticketDAO = DAO('tickets')
        ticket = ticketDAO.select_by_key(connection, 'id', id)
        
        if not ticket: 
            return redirect(url_for('tickets.lista_servicos'))

        with connection.cursor() as cursor:
            cursor.execute("SELECT get_prioridade(%s)", (id,))
            resultado = cursor.fetchone()
            prioridade = resultado[0] if resultado else 'Não Definida'
            
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            query_worklogs = """
                SELECT w.*, u.name as user_name 
                FROM worklogs w 
                JOIN users u ON w.user_id = u.id 
                WHERE w.ticket_id = %s 
                ORDER BY w.begun_at DESC
            """
            cursor.execute(query_worklogs, (id,))
            historico = cursor.fetchall()

    return render_template('ticket-profile.html', ticket=ticket, prioridade=prioridade, historico=historico)

@bp.route("/servico/<int:ticket_id>/worklog", methods=['GET', 'POST'])
def registrar_worklog(ticket_id):
    if request.method == 'POST':
        user_id = request.form.get('user_id')
        mensagem = request.form.get('mensagem')

        try:
            with connect(DB_URL) as connection:
                with connection.cursor() as cursor:
                    cursor.execute("CALL set_worklog(%s, %s, %s)", (ticket_id, user_id, mensagem))
                connection.commit()
            
            return redirect(url_for('tickets.perfil_servico', id=ticket_id))
            
        except Exception as e: 
            return f"Erro ao registrar worklog: {e}", 500
            
    with connect(DB_URL) as connection:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("SELECT id, name FROM users ORDER BY name")
            tecnicos = cursor.fetchall()
            
    return render_template('worklog-form.html', ticket_id=ticket_id, tecnicos=tecnicos)