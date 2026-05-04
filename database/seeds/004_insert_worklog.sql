INSERT INTO worklogs (ticket_id, user_id, begun_at, ended_at, message) VALUES
-- Interações do Suporte TI
(1, 6, '2026-04-28 08:15:00', '2026-04-28 09:00:00', 'Análise de logs no firewall. Nenhuma anomalia local identificada. Suspeita de rota no provedor.'),
(1, 6, '2026-04-28 10:30:00', '2026-04-28 11:45:00', 'Contato com a operadora realizado. Rota restabelecida e túneis IPsec subiram novamente. Chamado resolvido.'),
(2, 6, '2026-05-01 10:00:00', '2026-05-01 10:30:00', 'Ajustado o swapfile do Pop!_OS e limpo o cache do Docker. O sistema estabilizou.'),
(2, 6, '2026-05-02 09:00:00', NULL, 'Chamado reaberto. Usuário relata que ao subir os containers de banco a máquina volta a congelar. Investigando vazamento de memória.'),
(3, 10, '2026-05-02 08:30:00', NULL, 'Testando configurações do wlr-randr para mapear as portas HDMI corretamente no Hyprland.'),
(4, 10, '2026-05-02 10:15:00', '2026-05-02 10:25:00', 'Usuário adicionado à organização no GitHub com nível de acesso Developer. Resolvido.'),

-- Interações de Sistemas e ERP
(6, 2, '2026-04-25 10:30:00', '2026-04-25 11:45:00', 'Identificado problema de modelagem. Os valores estavam salvos como FLOAT.'),
(6, 2, '2026-04-26 09:00:00', '2026-04-26 14:00:00', 'Refatoração da base concluída: alterado para INTEGER (armazenando em centavos) para resolver os problemas de arredondamento. PR aprovado e resolvido.'),
(7, 9, '2026-04-29 11:30:00', '2026-04-29 12:45:00', 'O conector do Outlook 365 estava com a autenticação expirada. Refeita a conexão e fluxo testado com sucesso. Resolvido.'),
(8, 14, '2026-05-01 14:40:00', '2026-05-01 16:30:00', 'Criados índices nas tabelas de histórico. O tempo de resposta caiu de 45s para 3s. Monitorando em produção.'),
(9, 9, '2026-05-02 10:00:00', NULL, 'Analisando a extração do Excel. A coluna Mês/Ano veio como texto da filial, quebrando o passo de Alterar Tipo no Power Query.'),
(10, 2, '2026-05-02 11:30:00', '2026-05-02 11:50:00', 'Atualizado o Mason e reinstalado o tsserver. Erro de sintaxe sumiu.'),
(10, 2, '2026-05-02 14:15:00', NULL, 'Usuário reabriu relatando que o auto-import parou de funcionar. Revisando a configuração do nvim-cmp.'),

-- Interações do Recursos Humanos
(12, 11, '2026-04-28 14:30:00', '2026-04-28 15:45:00', 'Contrato de trabalho gerado, conta de email solicitada à TI e kit boas-vindas separado. Resolvido.'),
(13, 11, '2026-05-02 13:10:00', '2026-05-02 13:20:00', 'Batida inserida manualmente no sistema. Resolvido.'),
(14, 15, '2026-05-02 14:30:00', NULL, 'Analisando o espelho da folha de pagamento para verificar se o desconto foi devido a retroativo ou erro de sistema.'),

-- Interações da Manutenção Predial
(16, 7, '2026-05-01 15:05:00', '2026-05-01 16:30:00', 'Identificado curto no disjuntor do quadro elétrico. Disjuntor substituído e equipamento religado. Resolvido.'),
(17, 12, '2026-05-02 08:45:00', '2026-05-02 09:15:00', 'Pistão hidráulico trocado por um da reserva do estoque. Cadeira funcional. Resolvido.'),
(18, 7, '2026-05-02 11:00:00', NULL, 'Feita a vistoria. O problema não é a lâmpada, é o reator. Aguardando aprovação para comprar a peça na elétrica.');