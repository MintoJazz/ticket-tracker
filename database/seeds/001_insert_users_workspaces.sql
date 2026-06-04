INSERT INTO users (email, name, password) VALUES
('carlos.mendes@empresa.com', 'Carlos Mendes', 'hash123'),
('lucas.almeida@empresa.com', 'Lucas Almeida', 'hash123'),
('marina.costa@empresa.com', 'Marina Costa', 'hash123'),
('roberto.santos@empresa.com', 'Roberto Santos', 'hash123'),
('fernanda.lima@empresa.com', 'Fernanda Lima', 'hash123'),
('ana.souza@empresa.com', 'Ana Souza', 'hash123'),
('diego.alves@empresa.com', 'Diego Alves', 'hash123'),
('joao.ferreira@empresa.com', 'João Ferreira', 'hash123'),
('beatriz.rocha@empresa.com', 'Beatriz Rocha', 'hash123'),
('thiago.martins@empresa.com', 'Thiago Martins', 'hash123'),
('clara.silva@empresa.com', 'Clara Silva', 'hash123'),
('paulo.gomes@empresa.com', 'Paulo Gomes', 'hash123'),
('renata.nunes@empresa.com', 'Renata Nunes', 'hash123'),
('bruno.carvalho@empresa.com', 'Bruno Carvalho', 'hash123'),
('juliana.freitas@empresa.com', 'Juliana Freitas', 'hash123');

INSERT INTO workspaces (name) VALUES
('Suporte TI'),
('Sistemas e ERP'),
('Recursos Humanos'),
('Manutenção Predial');

INSERT INTO workspace_users (workspace_id, user_id, role) VALUES
(1, 5, 'ADMIN'),
(2, 5, 'ADMIN'),   
(3, 3, 'ADMIN'),
(4, 4, 'ADMIN'),
(1, 6, 'TECNICO'),
(1, 10, 'TECNICO'),
(2, 2, 'TECNICO'),
(2, 9, 'TECNICO'),
(2, 14, 'TECNICO'),
(3, 11, 'TECNICO'),
(3, 15, 'TECNICO'),
(4, 7, 'TECNICO'),
(4, 12, 'TECNICO');