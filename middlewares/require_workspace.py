from functools import wraps
from flask import session, jsonify

def require_workspace(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'workspace_id' not in session:
            return jsonify({"error": "workspace_id não definido na sessão. Selecione um workspace primeiro."}), 401
        kwargs['workspace_id'] = session['workspace_id']
        return f(*args, **kwargs)
    return decorated_function
