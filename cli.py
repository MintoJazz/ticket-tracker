import os
import click
from flask.cli import with_appcontext
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from config import DB_URL

def execute_sql_file(cursor, filepath):
    filename = os.path.basename(filepath)
    parent_folder = os.path.basename(os.path.dirname(filepath))
    
    click.echo(f"   -> Executando [{parent_folder}]: {filename}")
    
    with open(filepath, 'r', encoding='utf-8') as file:
        sql = file.read()
        cursor.execute(sql)

@click.command('db-push')
@click.option('--force', is_flag=True, help="Ignora a confirmação de exclusão dos dados.")
@with_appcontext
def db_push(force):
    """Sincroniza o banco executando todos os SQLs em ordem sequencial global."""
    
    if not DB_URL:
        click.secho("❌ Erro: A variável DB_URL não foi encontrada no arquivo .env", fg="red")
        return

    if not force: click.confirm('⚠️ Isso vai APAGAR todas as tabelas e dados do seu banco atual. Continuar?', abort=True)  # noqa: E701

    click.echo("========================================")
    click.echo("Sincronizando Banco de Dados (Reset de Schema)")
    click.echo("========================================")
    
    # Conexão 1: autocommit obrigatório para DROP/CREATE SCHEMA (não podem rodar dentro de transação)
    try:
        conn = psycopg2.connect(DB_URL)
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        click.secho("1. Limpando tabelas, funções e enums antigos...", fg="cyan")
        cursor.execute("DROP SCHEMA public CASCADE;")
        cursor.execute("CREATE SCHEMA public;")
        cursor.close()
        conn.close()
        
    except psycopg2.OperationalError as e:
        if "does not exist" in str(e):
            click.secho("\n❌ Erro: O banco de dados alvo não foi encontrado.", fg="red", bold=True)
            click.secho("Crie um banco de dados vazio no seu PostgreSQL (ex: CREATE DATABASE ticket_tracker;) antes de rodar este comando.", fg="yellow")
        else:
            click.secho(f"\n❌ Falha na conexão: {e}", fg="red")
        return

    # Conexão 2: transação normal para aplicar os arquivos SQL
    conn2 = None
    filepath = None
    try:
        click.secho("\n2. Coletando e aplicando arquivos SQL:", fg="cyan")
        
        sql_files = []
        base_dir = "database"

        for root, _, files in os.walk(base_dir): 
            for file in files:
                if file.endswith('.sql') and file != 'dump.sql': sql_files.append(os.path.join(root, file))  # noqa: E701

        sql_files.sort(key=lambda filepath: os.path.basename(filepath))
        
        if not sql_files:
            click.secho("Nenhum arquivo .sql encontrado na pasta database/ e subpastas.", fg="yellow")
            return

        conn2 = psycopg2.connect(DB_URL)
        cursor2 = conn2.cursor()

        for filepath in sql_files: execute_sql_file(cursor2, filepath)  # noqa: E701
        
        conn2.commit()
        cursor2.close()
        conn2.close()
        
        click.secho("\n✨ Sincronização concluída com sucesso! Banco pronto.", fg="green", bold=True)

    except Exception as e:
        if conn2:
            conn2.rollback()
        failed_file = os.path.basename(filepath) if filepath else 'Desconhecido'
        click.secho(f"\n❌ Falha na execução. O processo estourou no arquivo: {failed_file}", fg="red", bold=True)
        click.secho(f"Detalhe do erro: {e}", fg="red")