from flask import Blueprint, jsonify
from psycopg2 import connect
from psycopg2.extras import RealDictCursor

from config import DB_URL
from persistencias import DAO

bp = Blueprint('tickets', __name__)

@bp.route('/')
def lista_servicos():
    with connect(DB_URL) as connection:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("""
                SELECT t.*, ws.name as workspace_name 
                FROM tickets t
                LEFT JOIN workspaces ws ON t.workspace_id = ws.id
                ORDER BY t.id
            """)
            todos_tickets = cursor.fetchall()
    return jsonify({"tickets": todos_tickets})

@bp.route('/<int:ticket_id>')
def perfil_servico(ticket_id):
    with connect(DB_URL) as connection:
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("""
                SELECT t.*, ws.name as workspace_name 
                FROM tickets t
                LEFT JOIN workspaces ws ON t.workspace_id = ws.id
                WHERE t.id = %s
            """, (ticket_id,))
            ticket = cursor.fetchone()

        if not ticket: 
            return jsonify({"error": "Ticket não encontrado."}), 404
            
        with connection.cursor() as cursor:
            cursor.execute("SELECT get_prioridade(%s)", (ticket_id,))
            resultado = cursor.fetchone()
            prioridade = resultado[0] if resultado else 'Não Definida'
            
        with connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute("""
                SELECT w.*, u.name as user_name 
                FROM worklogs w 
                JOIN users u ON w.user_id = u.id 
                WHERE w.ticket_id = %s 
                ORDER BY w.begun_at DESC
            """, (ticket_id,))
            historico = cursor.fetchall()
            
    return jsonify({"ticket": ticket, "prioridade": prioridade, "historico": historico})