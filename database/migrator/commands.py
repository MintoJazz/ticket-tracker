import click
from flask.cli import with_appcontext
from .database import get_connection, execute_sql_folder

@click.group('db')
def db_cli():
    """Comandos para migração e controle do Banco de Dados."""
    pass

@db_cli.command('reset')
@click.option('--force', is_flag=True, help="Ignora a confirmação de exclusão dos dados.")
@with_appcontext
def reset(force):
    """Apaga e recria o schema public do banco."""
    if not force: 
        click.confirm('⚠️ Isso vai APAGAR todas as tabelas e dados. Continuar?', abort=True)
    
    conn = get_connection(autocommit=True)
    cursor = conn.cursor()
    click.secho("\n🧹 Limpando tabelas, funções e enums antigos...", fg="cyan")
    cursor.execute("DROP SCHEMA public CASCADE; CREATE SCHEMA public;")
    cursor.close()
    conn.close()
    click.secho("✨ Schema resetado com sucesso!", fg="green")

@db_cli.command('migrate')
@with_appcontext
def migrate():
    """Aplica as estruturas de tabelas e enums (pasta schemas)."""
    conn = get_connection()
    cursor = conn.cursor()
    try:
        execute_sql_folder(cursor, "schemas")
        conn.commit()
        click.secho("✨ Migrations aplicadas com sucesso!", fg="green")
    except Exception:
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

@db_cli.command('routines')
@with_appcontext
def routines():
    """Aplica ou atualiza functions e procedures (pasta functions)."""
    conn = get_connection()
    cursor = conn.cursor()
    try:
        # Aponta para a pasta onde suas funções estão no diretório "database"
        execute_sql_folder(cursor, "functions") 
        conn.commit()
        click.secho("✨ Funções e Procedures atualizadas!", fg="green")
    except Exception:
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

@db_cli.command('seed')
@with_appcontext
def seed():
    """Popula o banco com os dados iniciais (pasta seeds)."""
    conn = get_connection()
    cursor = conn.cursor()
    try:
        execute_sql_folder(cursor, "seeds")
        conn.commit()
        click.secho("✨ Banco populado com sucesso!", fg="green")
    except Exception:
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

@db_cli.command('push')
@click.option('--force', is_flag=True, help="Ignora confirmações.")
@click.pass_context
@with_appcontext
def push(ctx, force):
    """Executa o ciclo completo: reset, migrate, routines e seed."""
    click.echo("========================================")
    click.echo("Sincronização Completa do Banco de Dados")
    click.echo("========================================")
    
    ctx.invoke(reset, force=force)
    ctx.invoke(migrate)
    ctx.invoke(routines)
    ctx.invoke(seed)
    
    click.secho("\n🚀 Sincronização concluída com sucesso! Banco pronto.", fg="green", bold=True)