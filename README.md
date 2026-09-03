# TicketTracker (Trabalho Acadêmico - Banco de Dados)

Sistema de helpdesk multi-setor servindo uma **API JSON** construída com **Flask** e **PostgreSQL**. 

Este projeto foi desenvolvido como um **trabalho acadêmico** focado no estudo e aplicação de **regras de negócio centralizadas no banco de dados**. Toda a lógica relevante do sistema foi propositalmente implementada via **Functions**, **Stored Procedures** e **Triggers** em PL/pgSQL.

---

## 🎯 Propósito Escolar e Arquitetura

O objetivo principal deste projeto é demonstrar a capacidade de um Sistema Gerenciador de Banco de Dados (SGBD) de operar não apenas como um repositório passivo de dados, mas como um motor ativo de regras de negócio.

Para atingir este objetivo educacional, as seguintes decisões arquiteturais foram tomadas:
1. **Lógica Exclusiva no BD**: A aplicação Python (Flask) atua *apenas* como uma fina camada de roteamento, validando o payload e entregando JSON para o cliente. Nenhuma regra de negócio (como checar se um técnico já tem atendimento em andamento ou atualizar o status de um chamado) é resolvida no Python.
2. **Automações Reativas**: Triggers do PostgreSQL são usados para reagir a eventos de `INSERT` ou `UPDATE`. Por exemplo, quando a API simplesmente insere uma linha na tabela de `worklogs`, o SGBD é quem altera o status do ticket (fechar, reabrir, etc) sem que a API perceba.
3. **Máquina de Estados e Concorrência**: Constraints complexas que não podem ser resolvidas com `CHECK` ou `UNIQUE` (ex: bloqueio de atendimentos simultâneos) são validadas por Triggers com `RAISE EXCEPTION`.

O Frontend deste projeto não está incluso neste repositório. O Flask serve unicamente a **API JSON** consumida por ele.

---

## 🛠️ Stack Tecnológica

| Componente      | Tecnologia                     |
| --------------- | ------------------------------ |
| Backend API     | Python 3.10 + Flask 3.1        |
| Banco de Dados  | PostgreSQL 18                  |
| Driver de BD    | psycopg2-binary                |
| CLI Customizada | Click (integrado ao Flask CLI) |

---

## 🚀 Tutorial de Instalação e Execução

Siga os passos abaixo para rodar o backend localmente na sua máquina.

### 1. Clonar o repositório
```bash
git clone https://github.com/MintoJazz/ticket-tracker.git
cd ticket-tracker
```

### 2. Criar e Ativar Ambiente Virtual
```bash
python3 -m venv venv
source venv/bin/activate
```
*(No Windows, utilize `venv\Scripts\activate`)*

### 3. Instalar as Dependências
```bash
pip install -r requirements.txt
```

### 4. Configurar as Variáveis de Ambiente (Segurança)
Para facilitar a criação do ambiente seguro, foi desenvolvida uma CLI customizada. Copie o arquivo de exemplo e rode o comando de setup:
```bash
cp .env.example .env
flask setup env
```
O comando `cp` criará o arquivo base contendo as variáveis padrão (incluindo `FLASK_APP=main`). Em seguida, o comando `flask setup env` irá injetar uma `SECRET_KEY` criptograficamente segura e gerada dinamicamente dentro deste novo arquivo `.env`.

Abra o arquivo `.env` gerado e certifique-se de configurar a sua `DB_URL` com as credenciais do seu banco local:
```env
DB_URL=postgresql://seu_usuario:sua_senha@localhost:5432/ticket_tracker
```

### 5. Preparar o Banco de Dados (PostgreSQL)
Certifique-se de que o banco de dados especificado na `DB_URL` exista. Se não, entre no `psql` e crie:
```sql
CREATE DATABASE ticket_tracker;
```

### 6. Executar Migrações, Functions e Seeds
O projeto possui comandos CLI próprios para controlar o ciclo de vida do banco (schema, funções PL/pgSQL e inserts de teste).
Rode o comando abaixo para aplicar toda a estrutura e popular os dados de teste:
```bash
flask db push
```

### 7. Iniciar o Servidor
```bash
flask run --debug
```
A API estará rodando em `http://127.0.0.1:5000`.

---

## 📋 Documentação da API (Endpoints)

Todas as rotas retornam `JSON`. Todas as respostas são padronizadas com o padrão de projeto *Result*.

> **Nota:** Todos os endpoints a partir de `2. Dashboard` exigem que um workspace já tenha sido selecionado na sessão (`POST /workspaces/selecionar`). Caso contrário, retornarão HTTP 401.

### 1. Workspaces

**GET `/workspaces/selecionar`**
Lista todos os workspaces disponíveis.
```json
{
  "workspaces": [
    { "id": 1, "name": "Suporte TI", "description": "Atendimento Infra" }
  ]
}
```

**POST `/workspaces/selecionar`**
Define o workspace ativo na sessão.
- **Payload:** `{"workspace_id": 1}`
- **Resposta Sucesso (200):** `{"message": "Workspace selecionado com sucesso!", "workspace_id": 1}`
- **Resposta Erro (400):** `{"error": "O campo 'workspace_id' é obrigatório."}`

### 2. Dashboard & Métricas

**GET `/`**
Retorna métricas agregadas do workspace ativo e a lista global de worklogs.
```json
{
  "dashboard": [
    { "workspace_id": 1, "workspace_name": "Suporte TI", "total_tickets": 150, "open_tickets": 45, "finished_tickets": 105, "avg_worklog_time_hours": 2.5 }
  ],
  "worklogs": [
    { "id": 1, "ticket_id": 10, "user_id": 2, "message": "Iniciando análise...", "begun_at": "2026-09-03T10:00:00Z", "ended_at": "2026-09-03T11:30:00Z" }
  ]
}
```

**GET `/ranking`**
Retorna o ranking global de técnicos.
```json
{
  "ranking": [
    { "name": "João Silva", "worklogs_count": 42, "workspace_names": "Suporte TI, Infraestrutura" }
  ]
}
```

### 3. Serviços (Tickets)

**GET `/servicos/`**
Retorna todos os tickets do workspace ativo.
```json
{
  "tickets": [
    { "id": 10, "workspace_id": 1, "title": "PC não liga", "status": "ABERTO", "created_at": "2026-09-01T14:00:00Z" }
  ]
}
```

**GET `/servicos/<ticket_id>`**
Detalhes de um ticket, sua prioridade dinâmica e histórico de worklogs.
```json
{
  "ticket": { "id": 10, "status": "EM_ANDAMENTO", "workspace_name": "Suporte TI" },
  "prioridade": "Alta",
  "historico": [
    { "id": 1, "user_name": "João Silva", "message": "Iniciando...", "begun_at": "2026-09-03T10:00:00Z", "ended_at": null }
  ]
}
```

### 4. Worklogs (Atendimentos)

**GET `/worklogs/<ticket_id>/novo`**
Retorna dados para o frontend montar o formulário de worklog.
```json
{
  "ticket_id": 10,
  "tecnicos": [
    { "id": 2, "name": "João Silva" }
  ]
}
```

**POST `/worklogs/<ticket_id>/novo`**
Inicia um atendimento (dispara triggers de validação e estado no BD).
- **Payload:** `{"user_id": 2, "mensagem": "Analisando log"}`
- **Resposta Sucesso (201):** `{"message": "Worklog registrado com sucesso!"}`
- **Resposta Erro Regra de Negócio (400):** `{"error": "Regra de Negócio: O técnico já possui um worklog em andamento. Finalize-o antes de registrar um novo."}`

**POST `/worklogs/<log_id>/encerrar`**
Encerra um atendimento ativo (preenche data final).
- **Resposta Sucesso (200):** `{"message": "Atendimento encerrado com sucesso!"}`
