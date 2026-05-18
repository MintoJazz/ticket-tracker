--
-- PostgreSQL database dump
--

\restrict pZvwgjgm3j2tKIgwuk9zbwVwisvppQ1PuyIMupRIkFf6ZpIaVol2euxNtgaOzuM

-- Dumped from database version 18.3 (Ubuntu 18.3-1.pgdg22.04+1)
-- Dumped by pg_dump version 18.3 (Ubuntu 18.3-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: role_registry; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.role_registry AS ENUM (
    'ADMIN',
    'TECNICO'
);


ALTER TYPE public.role_registry OWNER TO postgres;

--
-- Name: status_registry; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.status_registry AS ENUM (
    'FINALIZADO',
    'CANCELADO',
    'EM ATENDIMENTO',
    'AGUARDANDO ATENDIMENTO',
    'SERVIÇO REABERTO'
);


ALTER TYPE public.status_registry OWNER TO postgres;

--
-- Name: get_dashboard(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_dashboard() RETURNS TABLE(workspace_id integer, workspace_name character varying, total_tickets bigint, open_tickets bigint, finished_tickets bigint, avg_worklog_time_hours numeric)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    RETURN QUERY
    SELECT 
        ws.id AS workspace_id,
        ws.name AS workspace_name,
        COUNT(t.id)::BIGINT AS total_tickets,
        COUNT(t.id) FILTER (WHERE t.status NOT IN ('FINALIZADO', 'CANCELADO'))::BIGINT AS open_tickets,
        COUNT(t.id) FILTER (WHERE t.status = 'FINALIZADO')::BIGINT AS finished_tickets,
        COALESCE(ROUND(AVG(get_worklog_time(t.created_at, max_min.ended_at)), 2), 0)::NUMERIC AS avg_worklog_time_hours
    FROM workspaces ws
    LEFT JOIN tickets t ON ws.id = t.workspace_id
    LEFT JOIN (
        SELECT ticket_id, MAX(ended_at) AS ended_at 
        FROM worklogs 
        GROUP BY ticket_id
    ) max_min ON t.id = max_min.ticket_id
    GROUP BY ws.id, ws.name
    ORDER BY ws.id;
END; 
$$;


ALTER FUNCTION public.get_dashboard() OWNER TO postgres;

--
-- Name: get_prioridade(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_prioridade(integer) RETURNS character varying
    LANGUAGE sql
    AS $_$
    SELECT CASE
        WHEN count < 2 THEN 'Baixa'
        WHEN count < 4 THEN 'Média'
        WHEN count > 3 THEN 'Alta'
    END AS priority FROM (SELECT ticket_id, COUNT(*) FROM worklogs a GROUP BY ticket_id) p WHERE p.ticket_id = $1;
$_$;


ALTER FUNCTION public.get_prioridade(integer) OWNER TO postgres;

--
-- Name: get_ranking_tecnicos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_ranking_tecnicos() RETURNS TABLE(name character varying, worklogs_count bigint)
    LANGUAGE sql
    AS $$
    SELECT u.name, COALESCE(t.count, 0) as worklogs_count 
    FROM users u 
    LEFT JOIN (
        SELECT user_id, COUNT(DISTINCT ticket_id) as count  
        FROM worklogs  
        GROUP BY user_id
    ) t ON u.id = t.user_id 
    WHERE u.id IN (SELECT user_id FROM workspace_users WHERE role = 'TECNICO')
    ORDER BY worklogs_count DESC;
$$;


ALTER FUNCTION public.get_ranking_tecnicos() OWNER TO postgres;

--
-- Name: get_worklog_time(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_worklog_time(p_begin timestamp without time zone, p_end timestamp without time zone) RETURNS numeric
    LANGUAGE sql
    AS $$
    SELECT (EXTRACT(EPOCH FROM (p_end - p_begin)) / 3600.0)::NUMERIC;
$$;


ALTER FUNCTION public.get_worklog_time(p_begin timestamp without time zone, p_end timestamp without time zone) OWNER TO postgres;

--
-- Name: reopen_ticket(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.reopen_ticket(IN p_ticket_id integer)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    UPDATE tickets SET status = 'SERVIÇO REABERTO' WHERE id = p_ticket_id;
END; 
$$;


ALTER PROCEDURE public.reopen_ticket(IN p_ticket_id integer) OWNER TO postgres;

--
-- Name: set_worklog(integer, integer, text); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.set_worklog(IN p_ticket_id integer, IN p_user_id integer, IN p_message text)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    INSERT INTO worklogs (ticket_id, user_id, message) 
    VALUES (p_ticket_id, p_user_id, p_message);
    
    IF p_message ILIKE '%resolvido%' THEN 
        UPDATE tickets SET status = 'FINALIZADO' WHERE id = p_ticket_id; 
    END IF;
END; 
$$;


ALTER PROCEDURE public.set_worklog(IN p_ticket_id integer, IN p_user_id integer, IN p_message text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    owner_id integer,
    workspace_id integer,
    title character varying(100),
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status public.status_registry DEFAULT 'AGUARDANDO ATENDIMENTO'::public.status_registry
);


ALTER TABLE public.tickets OWNER TO postgres;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_id_seq OWNER TO postgres;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(100),
    name character varying(100),
    password character varying(100)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: worklogs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.worklogs (
    id integer NOT NULL,
    ticket_id integer,
    user_id integer,
    begun_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ended_at timestamp without time zone,
    message text
);


ALTER TABLE public.worklogs OWNER TO postgres;

--
-- Name: worklogs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.worklogs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.worklogs_id_seq OWNER TO postgres;

--
-- Name: worklogs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.worklogs_id_seq OWNED BY public.worklogs.id;


--
-- Name: workspace_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workspace_users (
    workspace_id integer NOT NULL,
    user_id integer NOT NULL,
    role public.role_registry DEFAULT 'TECNICO'::public.role_registry
);


ALTER TABLE public.workspace_users OWNER TO postgres;

--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workspaces (
    id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE public.workspaces OWNER TO postgres;

--
-- Name: workspaces_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workspaces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workspaces_id_seq OWNER TO postgres;

--
-- Name: workspaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workspaces_id_seq OWNED BY public.workspaces.id;


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: worklogs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worklogs ALTER COLUMN id SET DEFAULT nextval('public.worklogs_id_seq'::regclass);


--
-- Name: workspaces id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspaces ALTER COLUMN id SET DEFAULT nextval('public.workspaces_id_seq'::regclass);


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tickets (id, owner_id, workspace_id, title, description, created_at, status) FROM stdin;
2	2	1	Lentidão no Pop!_OS	Sistema congelando ao usar o Docker pesado. Suspeito do consumo de RAM.	2026-05-01 09:30:00	SERVIÇO REABERTO
4	9	1	Acesso ao GitHub	Preciso de permissão no repositório do backend principal.	2026-05-02 10:00:00	FINALIZADO
5	11	1	Mouse com duplo clique	Botão esquerdo falhando intermitentemente.	2026-05-02 14:00:00	AGUARDANDO ATENDIMENTO
6	1	2	Erro de arredondamento	Cálculos financeiros do ERP estão perdendo precisão nas casas decimais.	2026-04-25 10:00:00	FINALIZADO
7	8	2	Power Automate falhando	O fluxo de aprovação de compras parou de enviar e-mails aos gerentes.	2026-04-29 11:15:00	FINALIZADO
8	5	2	Timeout banco de dados	Query do relatório de vendas está derrubando a conexão.	2026-05-01 14:30:00	EM ATENDIMENTO
9	13	2	Erro no Power Query	A Linguagem M está acusando erro de conversão de tipo na coluna de datas.	2026-05-02 09:45:00	EM ATENDIMENTO
10	2	2	Setup Neovim	Erro no LSP de TypeScript ao abrir arquivos antigos do projeto.	2026-05-02 11:20:00	SERVIÇO REABERTO
11	5	2	Refatoração de API	Migrar endpoint de relatórios de Flask para Next.js.	2026-05-02 15:30:00	AGUARDANDO ATENDIMENTO
12	5	3	Onboarding novo Dev	Preparar documentação de admissão para o novo desenvolvedor pleno.	2026-04-28 14:00:00	FINALIZADO
13	6	3	Ajuste de Ponto	Ponto não registrou na catraca do refeitório no dia 01/05.	2026-05-02 13:00:00	FINALIZADO
14	10	3	Dúvida Holerite	Desconto de plano de saúde veio duplicado este mês.	2026-05-02 14:15:00	EM ATENDIMENTO
15	12	3	Solicitação de Férias	Agendar férias para a segunda quinzena de julho.	2026-05-02 16:00:00	AGUARDANDO ATENDIMENTO
16	5	4	Ar Condicionado do Servidor	Equipamento do CPD desarmou. Risco de superaquecimento dos racks.	2026-05-01 15:00:00	FINALIZADO
17	2	4	Cadeira com defeito	O pistão da minha cadeira quebrou, não regula mais a altura.	2026-05-02 08:30:00	FINALIZADO
18	13	4	Lâmpada queimada	Sala de reuniões 3 está com meia luz.	2026-05-02 10:45:00	EM ATENDIMENTO
19	8	4	Projetor sem foco	Imagem do projetor principal está embaçada mesmo ajustando a lente.	2026-05-02 13:20:00	AGUARDANDO ATENDIMENTO
20	4	4	Vazamento no banheiro	Pia pingando constantemente.	2026-05-02 15:10:00	AGUARDANDO ATENDIMENTO
1	8	1	Queda de VPN	Usuários externos não conseguem autenticar na VPN corporativa.	2026-04-28 08:00:00	FINALIZADO
3	14	1	Configuração Hyprland	Meu monitor secundário não está sendo reconhecido no Wayland.	2026-05-02 08:15:00	FINALIZADO
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, name, password) FROM stdin;
1	carlos.mendes@empresa.com	Carlos Mendes	hash123
2	lucas.almeida@empresa.com	Lucas Almeida	hash123
3	marina.costa@empresa.com	Marina Costa	hash123
4	roberto.santos@empresa.com	Roberto Santos	hash123
5	fernanda.lima@empresa.com	Fernanda Lima	hash123
6	ana.souza@empresa.com	Ana Souza	hash123
7	diego.alves@empresa.com	Diego Alves	hash123
8	joao.ferreira@empresa.com	João Ferreira	hash123
9	beatriz.rocha@empresa.com	Beatriz Rocha	hash123
10	thiago.martins@empresa.com	Thiago Martins	hash123
11	clara.silva@empresa.com	Clara Silva	hash123
12	paulo.gomes@empresa.com	Paulo Gomes	hash123
13	renata.nunes@empresa.com	Renata Nunes	hash123
14	bruno.carvalho@empresa.com	Bruno Carvalho	hash123
15	juliana.freitas@empresa.com	Juliana Freitas	hash123
\.


--
-- Data for Name: worklogs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.worklogs (id, ticket_id, user_id, begun_at, ended_at, message) FROM stdin;
1	1	6	2026-04-28 08:15:00	2026-04-28 09:00:00	Análise de logs no firewall. Nenhuma anomalia local identificada. Suspeita de rota no provedor.
2	1	6	2026-04-28 10:30:00	2026-04-28 11:45:00	Contato com a operadora realizado. Rota restabelecida e túneis IPsec subiram novamente. Chamado resolvido.
3	2	6	2026-05-01 10:00:00	2026-05-01 10:30:00	Ajustado o swapfile do Pop!_OS e limpo o cache do Docker. O sistema estabilizou.
4	2	6	2026-05-02 09:00:00	\N	Chamado reaberto. Usuário relata que ao subir os containers de banco a máquina volta a congelar. Investigando vazamento de memória.
5	3	10	2026-05-02 08:30:00	\N	Testando configurações do wlr-randr para mapear as portas HDMI corretamente no Hyprland.
6	4	10	2026-05-02 10:15:00	2026-05-02 10:25:00	Usuário adicionado à organização no GitHub com nível de acesso Developer. Resolvido.
7	6	2	2026-04-25 10:30:00	2026-04-25 11:45:00	Identificado problema de modelagem. Os valores estavam salvos como FLOAT.
8	6	2	2026-04-26 09:00:00	2026-04-26 14:00:00	Refatoração da base concluída: alterado para INTEGER (armazenando em centavos) para resolver os problemas de arredondamento. PR aprovado e resolvido.
9	7	9	2026-04-29 11:30:00	2026-04-29 12:45:00	O conector do Outlook 365 estava com a autenticação expirada. Refeita a conexão e fluxo testado com sucesso. Resolvido.
10	8	14	2026-05-01 14:40:00	2026-05-01 16:30:00	Criados índices nas tabelas de histórico. O tempo de resposta caiu de 45s para 3s. Monitorando em produção.
11	9	9	2026-05-02 10:00:00	\N	Analisando a extração do Excel. A coluna Mês/Ano veio como texto da filial, quebrando o passo de Alterar Tipo no Power Query.
12	10	2	2026-05-02 11:30:00	2026-05-02 11:50:00	Atualizado o Mason e reinstalado o tsserver. Erro de sintaxe sumiu.
13	10	2	2026-05-02 14:15:00	\N	Usuário reabriu relatando que o auto-import parou de funcionar. Revisando a configuração do nvim-cmp.
14	12	11	2026-04-28 14:30:00	2026-04-28 15:45:00	Contrato de trabalho gerado, conta de email solicitada à TI e kit boas-vindas separado. Resolvido.
15	13	11	2026-05-02 13:10:00	2026-05-02 13:20:00	Batida inserida manualmente no sistema. Resolvido.
16	14	15	2026-05-02 14:30:00	\N	Analisando o espelho da folha de pagamento para verificar se o desconto foi devido a retroativo ou erro de sistema.
17	16	7	2026-05-01 15:05:00	2026-05-01 16:30:00	Identificado curto no disjuntor do quadro elétrico. Disjuntor substituído e equipamento religado. Resolvido.
18	17	12	2026-05-02 08:45:00	2026-05-02 09:15:00	Pistão hidráulico trocado por um da reserva do estoque. Cadeira funcional. Resolvido.
19	18	7	2026-05-02 11:00:00	\N	Feita a vistoria. O problema não é a lâmpada, é o reator. Aguardando aprovação para comprar a peça na elétrica.
20	1	14	2026-05-04 18:12:59.940802	\N	resolvido
21	3	10	2026-05-04 18:13:24.972051	\N	resolvido
\.


--
-- Data for Name: workspace_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workspace_users (workspace_id, user_id, role) FROM stdin;
1	5	ADMIN
2	5	ADMIN
3	3	ADMIN
4	4	ADMIN
1	6	TECNICO
1	10	TECNICO
2	2	TECNICO
2	9	TECNICO
2	14	TECNICO
3	11	TECNICO
3	15	TECNICO
4	7	TECNICO
4	12	TECNICO
\.


--
-- Data for Name: workspaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workspaces (id, name) FROM stdin;
1	Suporte TI
2	Sistemas e ERP
3	Recursos Humanos
4	Manutenção Predial
\.


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tickets_id_seq', 20, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 15, true);


--
-- Name: worklogs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.worklogs_id_seq', 21, true);


--
-- Name: workspaces_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workspaces_id_seq', 4, true);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: worklogs worklogs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worklogs
    ADD CONSTRAINT worklogs_pkey PRIMARY KEY (id);


--
-- Name: workspace_users workspace_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspace_users
    ADD CONSTRAINT workspace_users_pkey PRIMARY KEY (user_id, workspace_id);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: tickets tickets_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: worklogs worklogs_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worklogs
    ADD CONSTRAINT worklogs_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: worklogs worklogs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worklogs
    ADD CONSTRAINT worklogs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: workspace_users workspace_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspace_users
    ADD CONSTRAINT workspace_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workspace_users workspace_users_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workspace_users
    ADD CONSTRAINT workspace_users_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict pZvwgjgm3j2tKIgwuk9zbwVwisvppQ1PuyIMupRIkFf6ZpIaVol2euxNtgaOzuM

