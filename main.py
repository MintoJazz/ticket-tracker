from flask import Flask

from routes.dashboard import bp as dashboard_bp
from routes.ranking import bp as ranking_bp
from routes.tickets import bp as tickets_bp

app = Flask(__name__)

app.register_blueprint(dashboard_bp)
app.register_blueprint(ranking_bp)
app.register_blueprint(tickets_bp)