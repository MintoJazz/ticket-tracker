import os
import secrets
import shutil
import click
from flask.cli import AppGroup

setup_cli = AppGroup('setup')

@setup_cli.command('env')
def generate_env():
    """Gera o arquivo .env e injeta uma SECRET_KEY segura."""
    env_path = '.env'
    example_path = '.env.example'
    
    if not os.path.exists(env_path):
        if os.path.exists(example_path):
            shutil.copy(example_path, env_path)
            click.secho(f"✅ Arquivo {env_path} criado a partir do {example_path}.", fg="green")
        else:
            open(env_path, 'a').close()
            click.secho(f"✅ Arquivo {env_path} criado vazio.", fg="yellow")
    else:
        click.secho(f"ℹ️ Arquivo {env_path} já existe.", fg="cyan")

    secret_key = secrets.token_hex(32)
    
    with open(env_path, 'r') as f:
        content = f.read()
    
    if 'SECRET_KEY=sua_chave_secreta_aqui' in content:
        content = content.replace('SECRET_KEY=sua_chave_secreta_aqui', f'SECRET_KEY={secret_key}')
        with open(env_path, 'w') as f:
            f.write(content)
        click.secho("✨ SECRET_KEY gerada e inserida no .env com sucesso!", fg="green")
    elif 'SECRET_KEY=' in content:
        click.secho("⚠️ Uma SECRET_KEY já parece estar definida no .env. Nenhuma alteração foi feita.", fg="yellow")
    else:
        with open(env_path, 'a') as f:
            if not content.endswith('\n'):
                f.write('\n')
            f.write(f"SECRET_KEY={secret_key}\n")
        click.secho("✨ SECRET_KEY gerada e adicionada ao final do .env com sucesso!", fg="green")
