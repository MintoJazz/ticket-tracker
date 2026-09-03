class Result:
    def __init__(self, is_success, value=None, error=None, status_code=200):
        self.is_success = is_success
        self.value = value
        self.error = error
        self.status_code = status_code

    @classmethod
    def success(cls, value=None, status_code=200):
        return cls(True, value=value, status_code=status_code)

    @classmethod
    def failure(cls, error, status_code=400):
        return cls(False, error=error, status_code=status_code)
