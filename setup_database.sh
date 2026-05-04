#!/bin/bash

DB_USER="postgres"
DB_NAME="ticket_tracker"
DB_DIR="./database"

echo -n "Digite a senha do banco para o usuário '$DB_USER': "
read -s PGPASSWORD
echo ""

export PGPASSWORD

echo "========================================"
echo "Iniciando a construção do banco de dados"
echo "========================================"

echo "1. Recriando o banco de dados..."
psql -U $DB_USER -d postgres -f "$DB_DIR/setup.sql"

echo "2. Rodando as migrations em ordem..."
for file in $(ls $DB_DIR/migrations/*.sql | sort); do
  echo "   -> Executando migration: $file"
  psql -U $DB_USER -d $DB_NAME -f "$file"
done

echo "3. Criando funções e procedures..."
for file in $(ls $DB_DIR/functions/*.sql | sort); do
  echo "   -> Executando função: $file"
  psql -U $DB_USER -d $DB_NAME -f "$file"
done

echo "4. Populando o banco de dados (Seeds)..."
for file in $(ls $DB_DIR/seeds/*.sql | sort); do
  echo "   -> Inserindo seed: $file"
  psql -U $DB_USER -d $DB_NAME -f "$file"
done

unset PGPASSWORD

echo "========================================"
echo "Banco de dados construído com sucesso!"
echo "========================================"