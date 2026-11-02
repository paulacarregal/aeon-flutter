-- IDs 1 e 2 sao usuarios simulados criados em 02_seed.sql: Blair Willow e Ken.

-- Uso direto do package com score detalhado para Blair Willow.
SELECT
    l.nome,
    l.categoria,
    pkg_aeon_recomendacao.fn_calcular_afinidade(1, l.id_local) AS afinidade,
    pkg_aeon_recomendacao.fn_calcular_bonus_proximidade(1, l.id_local) AS bonus_proximidade,
    pkg_aeon_recomendacao.fn_calcular_bonus_impulsionamento(1, l.id_local) AS bonus_impulsionamento,
    pkg_aeon_recomendacao.fn_calcular_score_final(1, l.id_local) AS score_final
FROM local l
WHERE l.ativo = 'S'
ORDER BY score_final DESC;

-- Wrappers publicos preservados para compatibilidade com o backend Java.
SELECT
    l.nome,
    fn_calcular_afinidade(1, l.id_local) AS afinidade_wrapper,
    fn_resumo_local(l.id_local) AS resumo_wrapper,
    fn_classificar_afinidade(
        fn_calcular_afinidade(1, l.id_local)
    ) AS classificacao_wrapper
FROM local l
WHERE l.ativo = 'S'
ORDER BY afinidade_wrapper DESC;

-- Comparacao de perfis: Blair Willow tende a locais sociais/noturnos/premium.
SELECT
    l.nome,
    pkg_aeon_recomendacao.fn_calcular_score_final(1, l.id_local) AS score_blair,
    pkg_aeon_recomendacao.fn_calcular_score_final(2, l.id_local) AS score_ken
FROM local l
WHERE l.id_local IN (1, 4, 7)
ORDER BY l.id_local;

-- Impulsionamento contextual: bonus comercial so aparece com campanha ativa e contexto minimo.
SELECT
    l.nome,
    li.status,
    li.peso_bonus,
    pkg_aeon_recomendacao.fn_calcular_afinidade(1, l.id_local) AS afinidade_blair,
    pkg_aeon_recomendacao.fn_calcular_bonus_impulsionamento(1, l.id_local) AS bonus_impulsionamento_blair,
    pkg_aeon_recomendacao.fn_calcular_score_final(1, l.id_local) AS score_final_blair
FROM local l
LEFT JOIN local_impulsionamento li ON li.id_local = l.id_local
ORDER BY l.id_local;

-- Proximidade complementar para Ken: locais perto de experiencias fortes podem ganhar bonus.
SELECT
    l.nome,
    l.categoria,
    pkg_aeon_recomendacao.fn_calcular_afinidade(2, l.id_local) AS afinidade_ken,
    pkg_aeon_recomendacao.fn_calcular_bonus_proximidade(2, l.id_local) AS bonus_proximidade_ken,
    pkg_aeon_recomendacao.fn_calcular_bonus_impulsionamento(2, l.id_local) AS bonus_impulsionamento_ken,
    pkg_aeon_recomendacao.fn_calcular_score_final(2, l.id_local) AS score_final_ken
FROM local l
WHERE l.ativo = 'S'
ORDER BY score_final_ken DESC;

BEGIN
    pr_gerar_recomendacoes(1);
    pr_gerar_recomendacoes(2);
END;
/

SELECT
    u.nome AS usuario,
    l.nome AS local,
    r.score,
    r.data_recomendacao
FROM historico_recomendacao r
JOIN usuario u ON u.id_usuario = r.id_usuario
JOIN local l ON l.id_local = r.id_local
WHERE r.id_usuario IN (1, 2)
ORDER BY u.id_usuario, r.score DESC;

SELECT
    u.nome AS usuario,
    l.nome AS local,
    ar.tipo_recomendacao,
    ar.score_afinidade,
    ar.bonus_proximidade,
    ar.bonus_impulsionamento,
    ar.score_final,
    ar.justificativa,
    ar.data_evento
FROM auditoria_recomendacao ar
JOIN usuario u ON u.id_usuario = ar.id_usuario
JOIN local l ON l.id_local = ar.id_local
WHERE ar.id_usuario IN (1, 2)
ORDER BY ar.data_evento DESC, ar.score_final DESC;

SAVEPOINT demo_triggers;

-- Trigger TRG_AVALIACAO_ATUALIZA_MEDIA.
SELECT id_local, nome, nota_media
FROM local
WHERE id_local = 1;

INSERT INTO avaliacao (
    id_usuario,
    id_local,
    nota,
    comentario,
    data_avaliacao
) VALUES (
    2,
    1,
    3.5,
    'Avaliacao temporaria para demonstrar trigger de media.',
    SYSTIMESTAMP
);

SELECT
    l.id_local,
    l.nome,
    l.nota_media AS media_consolidada,
    ROUND(AVG(a.nota), 2) AS media_calculada
FROM local l
JOIN avaliacao a ON a.id_local = l.id_local
WHERE l.id_local = 1
GROUP BY l.id_local, l.nome, l.nota_media;

-- Trigger TRG_AUDITA_IMPULSIONAMENTO com INSERT e UPDATE.
INSERT INTO local_impulsionamento (
    id_impulsionamento,
    id_local,
    data_inicio,
    data_fim,
    peso_bonus,
    status,
    objetivo
) VALUES (
    99,
    6,
    TRUNC(SYSDATE),
    TRUNC(SYSDATE) + 7,
    3,
    'ATIVO',
    'Campanha temporaria para demonstrar auditoria de criacao.'
);

UPDATE local_impulsionamento
SET status = 'PAUSADO',
    peso_bonus = 4
WHERE id_impulsionamento = 2;

SELECT
    ai.id_auditoria,
    ai.id_impulsionamento,
    l.nome,
    ai.acao,
    ai.status_anterior,
    ai.status_novo,
    ai.peso_anterior,
    ai.peso_novo,
    ai.data_evento
FROM auditoria_impulsionamento ai
JOIN local l ON l.id_local = ai.id_local
ORDER BY ai.id_auditoria DESC;

ROLLBACK TO demo_triggers;

-- Dynamic SQL com SYS_REFCURSOR.
VAR rc REFCURSOR;
EXEC pr_buscar_recomendacoes_dinamicas(2, NULL, 'N', 4, 'SCORE', :rc);
PRINT rc;

VAR rc_impulsionados REFCURSOR;
EXEC pr_buscar_recomendacoes_dinamicas(1, 'Gastronomia', 'S', 4, 'NOTA', :rc_impulsionados);
PRINT rc_impulsionados;

-- Validacao dos objetos criados.
SELECT
    object_name,
    object_type,
    status
FROM user_objects
WHERE object_name IN (
    'PKG_AEON_RECOMENDACAO',
    'FN_CALCULAR_AFINIDADE',
    'FN_RESUMO_LOCAL',
    'FN_CLASSIFICAR_AFINIDADE',
    'PR_REGISTRAR_INTERACAO',
    'PR_GERAR_RECOMENDACOES',
    'PR_ATUALIZAR_NOTA_MEDIA_LOCAL',
    'PR_BUSCAR_RECOMENDACOES_DINAMICAS',
    'TRG_AVALIACAO_ATUALIZA_MEDIA',
    'TRG_AUDITA_IMPULSIONAMENTO'
)
ORDER BY object_type, object_name;

SELECT
    table_name
FROM user_tables
WHERE table_name IN (
    'LOCAL_IMPULSIONAMENTO',
    'AUDITORIA_IMPULSIONAMENTO',
    'AUDITORIA_RECOMENDACAO'
)
ORDER BY table_name;
