# main.py
from flask import Flask
from routes.dashboard import bp as dashboard_bp
from routes.ranking import bp as ranking_bp
from routes.tickets import bp as tickets_bp
from routes.worklogs import bp as worklogs_bp
from routes.workspaces import bp as workspaces_bp
from commands.db.commands import db_cli
from commands.setup import setup_cli
from config import SECRET_KEY

app = Flask(__name__)
app.secret_key = SECRET_KEY

app.register_blueprint(dashboard_bp)
app.register_blueprint(ranking_bp)
app.register_blueprint(tickets_bp, url_prefix='/servicos')
app.register_blueprint(worklogs_bp, url_prefix='/worklogs')
app.register_blueprint(workspaces_bp)

app.cli.add_command(db_cli)
app.cli.add_command(setup_cli)