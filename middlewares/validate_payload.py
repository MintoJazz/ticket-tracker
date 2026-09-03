from functools import wraps
from flask import jsonify, request

def validate_payload(*fields):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            data = request.get_json() or request.form
            if not data:
                return jsonify({"error": "Nenhum dado enviado."}), 400
            
            for field in fields:
                if field not in data or data.get(field) in (None, ""):
                    return jsonify({"error": f"O campo '{field}' é obrigatório."}), 400
                kwargs[field] = data.get(field)
            return f(*args, **kwargs)
        return decorated_function
    return decorator
