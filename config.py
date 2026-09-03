from os import getenv
from dotenv import load_dotenv

load_dotenv()
DB_URL = getenv('DB_URL')
SECRET_KEY = getenv('SECRET_KEY', 'fallback-inseguro-para-dev')