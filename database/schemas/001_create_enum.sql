CREATE TYPE status_registry AS ENUM (
    'FINALIZADO',
    'CANCELADO',
    'EM ATENDIMENTO',
    'AGUARDANDO ATENDIMENTO',
    'SERVIÇO REABERTO'
);

CREATE TYPE role_registry AS ENUM (
    'ADMIN',
    'TECNICO'
);