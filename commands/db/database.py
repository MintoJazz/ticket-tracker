import os
import click
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from config import DB_URL

def get_connection(autocommit=False):
    """Cria e retorna a conexão com o banco de dados."""
    if not DB_URL:
        click.secho("❌ Erro: A variável DB_URL não foi encontrada.", fg="red")
        raise click.Abort()
        
    try:
        conn = psycopg2.connect(DB_URL)
        if autocommit:
            conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        return conn
    except psycopg2.OperationalError as e:
        if "does not exist" in str(e):
            click.secho("\n❌ Erro: O banco de dados alvo não foi encontrado.", fg="red", bold=True)
        else:
            click.secho(f"\n❌ Falha na conexão: {e}", fg="red")
        raise click.Abort()

def execute_sql_folder(cursor, folder_name):
    """Lê e executa todos os arquivos .sql de um diretório específico em ordem alfabética."""
    base_dir = os.path.join("database", folder_name)
    
    if not os.path.exists(base_dir):
        click.secho(f"⚠️ Diretório ignorado (não encontrado): {base_dir}", fg="yellow")
        return
    
    sql_files = [f for f in os.listdir(base_dir) if f.endswith('.sql')]
    sql_files.sort()
    
    if not sql_files:
        return

    click.secho(f"\n📁 Aplicando {folder_name}...", fg="cyan", bold=True)
    for filename in sql_files:
        filepath = os.path.join(base_dir, filename)
        click.echo(f"   -> Executando: {filename}")
        
        with open(filepath, 'r', encoding='utf-8') as file:
            try:
                cursor.execute(file.read())
            except Exception as e:
                click.secho(f"\n❌ Falha na execução do arquivo: {filename}", fg="red", bold=True)
                click.secho(f"Detalhe: {e}", fg="red")
                raise click.Abort()