from functools import wraps
from flask import jsonify
from utils.result import Result

def jsonify_result(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        result = f(*args, **kwargs)
        if isinstance(result, Result):
            if not result.is_success:
                return jsonify({"error": result.error}), result.status_code
            return jsonify(result.value), result.status_code
        return result
    return decorated_function
