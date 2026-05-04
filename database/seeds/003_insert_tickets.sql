INSERT INTO tickets (title, description, created_at, owner_id, workspace_id, status) VALUES
-- Suporte TI (Workspace 1)
('Queda de VPN', 'Usuários externos não conseguem autenticar na VPN corporativa.', '2026-04-28 08:00:00', 8, 1, 'FINALIZADO'),
('Lentidão no Pop!_OS', 'Sistema congelando ao usar o Docker pesado. Suspeito do consumo de RAM.', '2026-05-01 09:30:00', 2, 1, 'SERVIÇO REABERTO'),
('Configuração Hyprland', 'Meu monitor secundário não está sendo reconhecido no Wayland.', '2026-05-02 08:15:00', 14, 1, 'EM ATENDIMENTO'),
('Acesso ao GitHub', 'Preciso de permissão no repositório do backend principal.', '2026-05-02 10:00:00', 9, 1, 'FINALIZADO'),
('Mouse com duplo clique', 'Botão esquerdo falhando intermitentemente.', '2026-05-02 14:00:00', 11, 1, 'AGUARDANDO ATENDIMENTO'),

-- Sistemas e ERP (Workspace 2)
('Erro de arredondamento', 'Cálculos financeiros do ERP estão perdendo precisão nas casas decimais.', '2026-04-25 10:00:00', 1, 2, 'FINALIZADO'),
('Power Automate falhando', 'O fluxo de aprovação de compras parou de enviar e-mails aos gerentes.', '2026-04-29 11:15:00', 8, 2, 'FINALIZADO'),
('Timeout banco de dados', 'Query do relatório de vendas está derrubando a conexão.', '2026-05-01 14:30:00', 5, 2, 'EM ATENDIMENTO'),
('Erro no Power Query', 'A Linguagem M está acusando erro de conversão de tipo na coluna de datas.', '2026-05-02 09:45:00', 13, 2, 'EM ATENDIMENTO'),
('Setup Neovim', 'Erro no LSP de TypeScript ao abrir arquivos antigos do projeto.', '2026-05-02 11:20:00', 2, 2, 'SERVIÇO REABERTO'),
('Refatoração de API', 'Migrar endpoint de relatórios de Flask para Next.js.', '2026-05-02 15:30:00', 5, 2, 'AGUARDANDO ATENDIMENTO'),

-- Recursos Humanos (Workspace 3)
('Onboarding novo Dev', 'Preparar documentação de admissão para o novo desenvolvedor pleno.', '2026-04-28 14:00:00', 5, 3, 'FINALIZADO'),
('Ajuste de Ponto', 'Ponto não registrou na catraca do refeitório no dia 01/05.', '2026-05-02 13:00:00', 6, 3, 'FINALIZADO'),
('Dúvida Holerite', 'Desconto de plano de saúde veio duplicado este mês.', '2026-05-02 14:15:00', 10, 3, 'EM ATENDIMENTO'),
('Solicitação de Férias', 'Agendar férias para a segunda quinzena de julho.', '2026-05-02 16:00:00', 12, 3, 'AGUARDANDO ATENDIMENTO'),

-- Manutenção Predial (Workspace 4)
('Ar Condicionado do Servidor', 'Equipamento do CPD desarmou. Risco de superaquecimento dos racks.', '2026-05-01 15:00:00', 5, 4, 'FINALIZADO'),
('Cadeira com defeito', 'O pistão da minha cadeira quebrou, não regula mais a altura.', '2026-05-02 08:30:00', 2, 4, 'FINALIZADO'),
('Lâmpada queimada', 'Sala de reuniões 3 está com meia luz.', '2026-05-02 10:45:00', 13, 4, 'EM ATENDIMENTO'),
('Projetor sem foco', 'Imagem do projetor principal está embaçada mesmo ajustando a lente.', '2026-05-02 13:20:00', 8, 4, 'AGUARDANDO ATENDIMENTO'),
('Vazamento no banheiro', 'Pia pingando constantemente.', '2026-05-02 15:10:00', 4, 4, 'AGUARDANDO ATENDIMENTO');