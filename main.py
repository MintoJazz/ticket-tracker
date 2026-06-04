# main.py
from flask import Flask
from routes.dashboard import bp as dashboard_bp
from routes.ranking import bp as ranking_bp
from routes.tickets import bp as tickets_bp
from routes.worklogs import bp as worklogs_bp
from database.migrator.commands import db_cli

app = Flask(__name__)
app.secret_key = '4f8b2c9a1d3e5f76b8a0c2d4e6f8a1b3c5d7e9f0a2b4c6d8e0f2a4b6c8d0e2f4'

app.register_blueprint(dashboard_bp)
app.register_blueprint(ranking_bp)
app.register_blueprint(tickets_bp, url_prefix='/servicos')
app.register_blueprint(worklogs_bp, url_prefix='/worklogs')

app.cli.add_command(db_cli)