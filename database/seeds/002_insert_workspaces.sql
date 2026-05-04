INSERT INTO workspaces (name) VALUES
('Suporte TI'),             -- ID 1
('Sistemas e ERP'),         -- ID 2
('Recursos Humanos'),       -- ID 3
('Manutenção Predial');     -- ID 4

INSERT INTO workspace_users (workspace_id, user_id, role) VALUES
-- Gestores (ADMIN)
(1, 5, 'ADMIN'),   -- Fernanda (TI e Sistemas)
(2, 5, 'ADMIN'),   
(3, 3, 'ADMIN'),   -- Marina (RH)
(4, 4, 'ADMIN'),   -- Roberto (Manutenção)

-- Técnicos Suporte TI
(1, 6, 'TECNICO'), -- Ana
(1, 10, 'TECNICO'),-- Thiago

-- Técnicos Sistemas e ERP
(2, 2, 'TECNICO'), -- Lucas
(2, 9, 'TECNICO'), -- Beatriz
(2, 14, 'TECNICO'),-- Bruno

-- Analistas RH
(3, 11, 'TECNICO'),-- Clara
(3, 15, 'TECNICO'),-- Juliana

-- Técnicos Manutenção
(4, 7, 'TECNICO'), -- Diego
(4, 12, 'TECNICO');-- Paulo