-- IDs 1 e 2 sao usuarios simulados criados em 02_seed.sql: Blair Willow e Ken.
SELECT
    l.nome,
    l.categoria,
    fn_calcular_afinidade(1, l.id_local) AS afinidade
FROM local l
WHERE l.ativo = 'S'
ORDER BY afinidade DESC;

SELECT
    u.nome,
    fn_calcular_afinidade(u.id_usuario, 7) AS afinidade_vista_rooftop
FROM usuario u
WHERE u.id_usuario IN (1, 2)
ORDER BY afinidade_vista_rooftop DESC;

SELECT
    fn_calcular_afinidade(1, 1) AS blair,
    fn_calcular_afinidade(2, 1) AS ken
FROM dual;

SELECT
    fn_calcular_afinidade(1, 4) AS blair_parque,
    fn_calcular_afinidade(2, 4) AS ken_parque
FROM dual;

SELECT fn_resumo_local(1) AS resumo
FROM dual;

SELECT fn_classificar_afinidade(25) AS classificacao
FROM dual;

SELECT fn_classificar_afinidade(55) AS classificacao
FROM dual;

SELECT fn_classificar_afinidade(85) AS classificacao
FROM dual;

SELECT
    l.nome,
    fn_calcular_afinidade(1, l.id_local) AS score,
    fn_classificar_afinidade(
        fn_calcular_afinidade(1, l.id_local)
    ) AS classificacao
FROM local l
WHERE l.ativo = 'S'
ORDER BY score DESC;

BEGIN
    pr_gerar_recomendacoes(1);
END;
/

SELECT
    l.nome,
    r.score,
    r.data_recomendacao
FROM historico_recomendacao r
JOIN local l ON l.id_local = r.id_local
WHERE r.id_usuario = 1
ORDER BY r.score DESC;

BEGIN
    pr_registrar_interacao(
        1,
        3,
        'SALVOU'
    );
END;
/

SELECT fn_calcular_afinidade(2, 7) AS score_antes_interacao
FROM dual;

BEGIN
    pr_registrar_interacao(
        2,
        7,
        'SALVOU'
    );
END;
/

SELECT fn_calcular_afinidade(2, 7) AS score_depois_interacao
FROM dual;

SELECT
    id_local,
    nome,
    nota_media
FROM local
WHERE id_local = 1;

BEGIN
    pr_atualizar_nota_media_local(1);
END;
/

SELECT
    id_local,
    nome,
    nota_media
FROM local
WHERE id_local = 1;

SELECT
    id_local,
    ROUND(AVG(nota), 2) AS media_avaliacoes
FROM avaliacao
WHERE id_local = 1
GROUP BY id_local;

BEGIN
    pr_gerar_recomendacoes(2);
END;
/

SELECT
    l.nome,
    r.score,
    fn_resumo_local(l.id_local) AS resumo
FROM historico_recomendacao r
JOIN local l ON l.id_local = r.id_local
WHERE r.id_usuario = 2
ORDER BY r.score DESC;

SELECT
    object_name,
    object_type,
    status
FROM user_objects
WHERE object_name IN (
    'FN_CALCULAR_AFINIDADE',
    'FN_RESUMO_LOCAL',
    'FN_CLASSIFICAR_AFINIDADE',
    'PR_REGISTRAR_INTERACAO',
    'PR_GERAR_RECOMENDACOES',
    'PR_ATUALIZAR_NOTA_MEDIA_LOCAL'
)
ORDER BY object_type, object_name;
