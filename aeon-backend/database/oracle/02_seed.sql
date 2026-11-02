INSERT INTO usuario (
    id_usuario,
    firebase_uid,
    nome,
    perfil,
    data_cadastro,
    prefere_premium,
    prefere_novidade,
    prefere_ativo,
    prefere_diurno,
    prefere_social,
    prefere_outdoor
) VALUES (
    1,
    'uid-demo-blair',
    'Blair Willow',
    'Social Noturno Premium',
    SYSTIMESTAMP - INTERVAL '20' DAY,
    'S',
    'N',
    'N',
    'N',
    'S',
    'N'
);

INSERT INTO usuario (
    id_usuario,
    firebase_uid,
    nome,
    perfil,
    data_cadastro,
    prefere_premium,
    prefere_novidade,
    prefere_ativo,
    prefere_diurno,
    prefere_social,
    prefere_outdoor
) VALUES (
    2,
    'uid-demo-ken',
    'Ken',
    'Outdoor Diurno Ativo',
    SYSTIMESTAMP - INTERVAL '15' DAY,
    'N',
    'N',
    'S',
    'S',
    'N',
    'S'
);

INSERT INTO usuario (
    id_usuario,
    firebase_uid,
    nome,
    perfil,
    data_cadastro,
    prefere_premium,
    prefere_novidade,
    prefere_ativo,
    prefere_diurno,
    prefere_social,
    prefere_outdoor
) VALUES (
    3,
    'uid-demo-clara',
    'Clara Souza',
    'Cacador de Novidades',
    SYSTIMESTAMP - INTERVAL '7' DAY,
    'N',
    'S',
    'N',
    'S',
    'S',
    'N'
);

INSERT INTO local (
    id_local,
    nome,
    categoria,
    latitude,
    longitude,
    endereco,
    nota_media,
    ativo,
    price_level,
    indoor,
    daytime,
    nightlife
) VALUES (
    1,
    'Bistro Aurora',
    'Gastronomia',
    -23.561684,
    -46.655981,
    'Av. Paulista, 1000 - Sao Paulo',
    4.7,
    'S',
    3,
    'S',
    'N',
    'S'
);

INSERT INTO local (
    id_local,
    nome,
    categoria,
    latitude,
    longitude,
    endereco,
    nota_media,
    ativo,
    price_level,
    indoor,
    daytime,
    nightlife
) VALUES (
    2,
    'Galeria SP',
    'Cultura',
    -23.550520,
    -46.633308,
    'Rua das Artes, 45 - Sao Paulo',
    4.5,
    'S',
    2,
    'S',
    'S',
    'N'
);

INSERT INTO local (
    id_local,
    nome,
    categoria,
    latitude,
    longitude,
    endereco,
    nota_media,
    ativo,
    price_level,
    indoor,
    daytime,
    nightlife
) VALUES (
    3,
    'Mercado Gourmet',
    'Gastronomia',
    -23.544901,
    -46.635200,
    'Rua da Cantina, 88 - Sao Paulo',
    4.6,
    'S',
    3,
    'S',
    'S',
    'S'
);

INSERT INTO local (
    id_local,
    nome,
    categoria,
    latitude,
    longitude,
    endereco,
    nota_media,
    ativo,
    price_level,
    indoor,
    daytime,
    nightlife
) VALUES (
    4,
    'Parque Verde',
    'Outdoor',
    -23.587416,
    -46.657634,
    'Av. Verde, 120 - Sao Paulo',
    4.8,
    'S',
    1,
    'N',
    'S',
    'N'
);

INSERT INTO local (
    id_local,
    nome,
    categoria,
    latitude,
    longitude,
    endereco,
    nota_media,
    ativo,
    price_level,
    indoor,
    daytime,
    nightlife
) VALUES (
    5,
    'Sky Lounge',
    'Vida Noturna',
    -23.566100,
    -46.684000,
    'Rua Horizonte, 210 - Sao Paulo',
    4.4,
    'S',
    4,
    'S',
    'N',
    'S'
);

INSERT INTO local (
    id_local,
    nome,
    categoria,
    latitude,
    longitude,
    endereco,
    nota_media,
    ativo,
    price_level,
    indoor,
    daytime,
    nightlife
) VALUES (
    6,
    'Museu Urbano',
    'Cultura',
    -23.548900,
    -46.638800,
    'Praca Historica, 33 - Sao Paulo',
    4.8,
    'S',
    2,
    'S',
    'S',
    'N'
);

INSERT INTO local (
    id_local,
    nome,
    categoria,
    latitude,
    longitude,
    endereco,
    nota_media,
    ativo,
    price_level,
    indoor,
    daytime,
    nightlife
) VALUES (
    7,
    'Vista Rooftop',
    'Experiencia',
    -23.569800,
    -46.668700,
    'Rua Panoramica, 500 - Sao Paulo',
    4.9,
    'S',
    4,
    'N',
    'N',
    'S'
);

INSERT INTO tag (id_tag, nome) VALUES (1, 'coffee');
INSERT INTO tag (id_tag, nome) VALUES (2, 'culture');
INSERT INTO tag (id_tag, nome) VALUES (3, 'gastronomy');
INSERT INTO tag (id_tag, nome) VALUES (4, 'social');
INSERT INTO tag (id_tag, nome) VALUES (5, 'night');
INSERT INTO tag (id_tag, nome) VALUES (6, 'day');
INSERT INTO tag (id_tag, nome) VALUES (7, 'outdoor');
INSERT INTO tag (id_tag, nome) VALUES (8, 'active');
INSERT INTO tag (id_tag, nome) VALUES (9, 'premium');
INSERT INTO tag (id_tag, nome) VALUES (10, 'new');
INSERT INTO tag (id_tag, nome) VALUES (11, 'calm');
INSERT INTO tag (id_tag, nome) VALUES (12, 'experience');
INSERT INTO tag (id_tag, nome) VALUES (13, 'rated');
INSERT INTO tag (id_tag, nome) VALUES (14, 'urban');
INSERT INTO tag (id_tag, nome) VALUES (15, 'music');
INSERT INTO tag (id_tag, nome) VALUES (16, 'nature');

INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (1, 3);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (1, 4);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (1, 5);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (1, 9);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (1, 15);

INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (2, 2);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (2, 6);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (2, 7);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (2, 8);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (2, 16);

INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (3, 1);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (3, 2);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (3, 4);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (3, 10);
INSERT INTO usuario_tag (id_usuario, id_tag) VALUES (3, 14);

INSERT INTO local_tag (id_local, id_tag) VALUES (1, 3);
INSERT INTO local_tag (id_local, id_tag) VALUES (1, 4);
INSERT INTO local_tag (id_local, id_tag) VALUES (1, 5);
INSERT INTO local_tag (id_local, id_tag) VALUES (1, 9);
INSERT INTO local_tag (id_local, id_tag) VALUES (1, 15);

INSERT INTO local_tag (id_local, id_tag) VALUES (2, 2);
INSERT INTO local_tag (id_local, id_tag) VALUES (2, 6);
INSERT INTO local_tag (id_local, id_tag) VALUES (2, 10);
INSERT INTO local_tag (id_local, id_tag) VALUES (2, 14);

INSERT INTO local_tag (id_local, id_tag) VALUES (3, 3);
INSERT INTO local_tag (id_local, id_tag) VALUES (3, 4);
INSERT INTO local_tag (id_local, id_tag) VALUES (3, 5);
INSERT INTO local_tag (id_local, id_tag) VALUES (3, 9);

INSERT INTO local_tag (id_local, id_tag) VALUES (4, 6);
INSERT INTO local_tag (id_local, id_tag) VALUES (4, 7);
INSERT INTO local_tag (id_local, id_tag) VALUES (4, 8);
INSERT INTO local_tag (id_local, id_tag) VALUES (4, 11);
INSERT INTO local_tag (id_local, id_tag) VALUES (4, 16);

INSERT INTO local_tag (id_local, id_tag) VALUES (5, 4);
INSERT INTO local_tag (id_local, id_tag) VALUES (5, 5);
INSERT INTO local_tag (id_local, id_tag) VALUES (5, 9);
INSERT INTO local_tag (id_local, id_tag) VALUES (5, 12);

INSERT INTO local_tag (id_local, id_tag) VALUES (6, 2);
INSERT INTO local_tag (id_local, id_tag) VALUES (6, 6);
INSERT INTO local_tag (id_local, id_tag) VALUES (6, 13);
INSERT INTO local_tag (id_local, id_tag) VALUES (6, 14);

INSERT INTO local_tag (id_local, id_tag) VALUES (7, 4);
INSERT INTO local_tag (id_local, id_tag) VALUES (7, 5);
INSERT INTO local_tag (id_local, id_tag) VALUES (7, 7);
INSERT INTO local_tag (id_local, id_tag) VALUES (7, 9);
INSERT INTO local_tag (id_local, id_tag) VALUES (7, 10);
INSERT INTO local_tag (id_local, id_tag) VALUES (7, 12);

INSERT INTO interacao_usuario (id_usuario, id_local, tipo_interacao, data_interacao)
VALUES (1, 1, 'SALVOU', SYSTIMESTAMP - INTERVAL '8' DAY);

INSERT INTO interacao_usuario (id_usuario, id_local, tipo_interacao, data_interacao)
VALUES (1, 3, 'CURTIU', SYSTIMESTAMP - INTERVAL '6' DAY);

INSERT INTO interacao_usuario (id_usuario, id_local, tipo_interacao, data_interacao)
VALUES (1, 5, 'VISITOU', SYSTIMESTAMP - INTERVAL '4' DAY);

INSERT INTO interacao_usuario (id_usuario, id_local, tipo_interacao, data_interacao)
VALUES (1, 4, 'IGNOROU', SYSTIMESTAMP - INTERVAL '2' DAY);

INSERT INTO interacao_usuario (id_usuario, id_local, tipo_interacao, data_interacao)
VALUES (2, 4, 'VISITOU', SYSTIMESTAMP - INTERVAL '9' DAY);

INSERT INTO interacao_usuario (id_usuario, id_local, tipo_interacao, data_interacao)
VALUES (2, 6, 'CURTIU', SYSTIMESTAMP - INTERVAL '5' DAY);

INSERT INTO interacao_usuario (id_usuario, id_local, tipo_interacao, data_interacao)
VALUES (2, 7, 'IGNOROU', SYSTIMESTAMP - INTERVAL '1' DAY);

INSERT INTO interacao_usuario (id_usuario, id_local, tipo_interacao, data_interacao)
VALUES (2, 1, 'IGNOROU', SYSTIMESTAMP - INTERVAL '2' DAY);

INSERT INTO interacao_usuario (id_usuario, id_local, tipo_interacao, data_interacao)
VALUES (3, 2, 'SALVOU', SYSTIMESTAMP - INTERVAL '6' DAY);

INSERT INTO interacao_usuario (id_usuario, id_local, tipo_interacao, data_interacao)
VALUES (3, 1, 'CURTIU', SYSTIMESTAMP - INTERVAL '3' DAY);

INSERT INTO avaliacao (id_usuario, id_local, nota, comentario, data_avaliacao)
VALUES (1, 1, 4.8, 'Boa experiencia social e gastronomica.', SYSTIMESTAMP - INTERVAL '7' DAY);

INSERT INTO avaliacao (id_usuario, id_local, nota, comentario, data_avaliacao)
VALUES (1, 3, 4.7, 'Ambiente social com boas opcoes gastronomicas.', SYSTIMESTAMP - INTERVAL '6' DAY);

INSERT INTO avaliacao (id_usuario, id_local, nota, comentario, data_avaliacao)
VALUES (1, 5, 4.5, 'Boa experiencia noturna.', SYSTIMESTAMP - INTERVAL '4' DAY);

INSERT INTO avaliacao (id_usuario, id_local, nota, comentario, data_avaliacao)
VALUES (2, 4, 4.9, 'Lugar tranquilo e aberto.', SYSTIMESTAMP - INTERVAL '9' DAY);

INSERT INTO avaliacao (id_usuario, id_local, nota, comentario, data_avaliacao)
VALUES (2, 6, 4.6, 'Cultura durante o dia combina com meu perfil.', SYSTIMESTAMP - INTERVAL '5' DAY);

INSERT INTO avaliacao (id_usuario, id_local, nota, comentario, data_avaliacao)
VALUES (2, 1, 2.4, 'Ambiente noturno e fechado nao combina com meu perfil.', SYSTIMESTAMP - INTERVAL '2' DAY);

INSERT INTO avaliacao (id_usuario, id_local, nota, comentario, data_avaliacao)
VALUES (3, 2, 4.6, 'Agenda cultural interessante.', SYSTIMESTAMP - INTERVAL '6' DAY);

INSERT INTO avaliacao (id_usuario, id_local, nota, comentario, data_avaliacao)
VALUES (3, 1, 4.4, 'Bistro confortavel e urbano.', SYSTIMESTAMP - INTERVAL '3' DAY);

INSERT INTO local_impulsionamento (
    id_impulsionamento,
    id_local,
    data_inicio,
    data_fim,
    peso_bonus,
    status,
    objetivo,
    data_criacao
) VALUES (
    1,
    1,
    TRUNC(SYSDATE) - 5,
    TRUNC(SYSDATE) + 20,
    8,
    'ATIVO',
    'Promover experiencia gastronomica premium para perfis sociais.',
    SYSTIMESTAMP - INTERVAL '5' DAY
);

INSERT INTO local_impulsionamento (
    id_impulsionamento,
    id_local,
    data_inicio,
    data_fim,
    peso_bonus,
    status,
    objetivo,
    data_criacao
) VALUES (
    2,
    7,
    TRUNC(SYSDATE) - 3,
    TRUNC(SYSDATE) + 15,
    6,
    'ATIVO',
    'Apoiar descoberta complementar proxima de jornadas outdoor e experiencia.',
    SYSTIMESTAMP - INTERVAL '3' DAY
);

INSERT INTO local_impulsionamento (
    id_impulsionamento,
    id_local,
    data_inicio,
    data_fim,
    peso_bonus,
    status,
    objetivo,
    data_criacao
) VALUES (
    3,
    5,
    TRUNC(SYSDATE) - 10,
    TRUNC(SYSDATE) + 10,
    10,
    'PAUSADO',
    'Campanha pausada para demonstrar ausencia de bonus comercial.',
    SYSTIMESTAMP - INTERVAL '10' DAY
);

INSERT INTO local_impulsionamento (
    id_impulsionamento,
    id_local,
    data_inicio,
    data_fim,
    peso_bonus,
    status,
    objetivo,
    data_criacao
) VALUES (
    4,
    2,
    TRUNC(SYSDATE) - 30,
    TRUNC(SYSDATE) - 1,
    5,
    'ENCERRADO',
    'Campanha encerrada para validar janela de vigencia.',
    SYSTIMESTAMP - INTERVAL '30' DAY
);

COMMIT;
