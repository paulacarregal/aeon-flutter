CREATE OR REPLACE FUNCTION fn_calcular_afinidade (
    p_id_usuario IN NUMBER,
    p_id_local IN NUMBER
) RETURN NUMBER
IS
    v_usuario_count NUMBER;
    v_local_count NUMBER;
    v_categoria local.categoria%TYPE;
    v_price_level local.price_level%TYPE;
    v_indoor local.indoor%TYPE;
    v_daytime local.daytime%TYPE;
    v_prefere_premium usuario.prefere_premium%TYPE;
    v_prefere_novidade usuario.prefere_novidade%TYPE;
    v_prefere_ativo usuario.prefere_ativo%TYPE;
    v_prefere_diurno usuario.prefere_diurno%TYPE;
    v_prefere_social usuario.prefere_social%TYPE;
    v_prefere_outdoor usuario.prefere_outdoor%TYPE;
    v_tags_comuns NUMBER := 0;
    v_contexto_score NUMBER := 0;
    v_historico_score NUMBER := 0;
    v_direto_score NUMBER := 0;
    v_avaliacao_score NUMBER := 0;
    v_positivas_categoria NUMBER := 0;
    v_ignoradas_categoria NUMBER := 0;
    v_positivas_local NUMBER := 0;
    v_media_categoria NUMBER := 0;
    v_tem_tag NUMBER := 0;
    v_score NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_usuario_count
    FROM usuario
    WHERE id_usuario = p_id_usuario;

    IF v_usuario_count = 0 THEN
        RETURN 0;
    END IF;

    SELECT COUNT(*)
    INTO v_local_count
    FROM local
    WHERE id_local = p_id_local
      AND ativo = 'S';

    IF v_local_count = 0 THEN
        RETURN 0;
    END IF;

    SELECT
        l.categoria,
        l.price_level,
        l.indoor,
        l.daytime,
        u.prefere_premium,
        u.prefere_novidade,
        u.prefere_ativo,
        u.prefere_diurno,
        u.prefere_social,
        u.prefere_outdoor
    INTO
        v_categoria,
        v_price_level,
        v_indoor,
        v_daytime,
        v_prefere_premium,
        v_prefere_novidade,
        v_prefere_ativo,
        v_prefere_diurno,
        v_prefere_social,
        v_prefere_outdoor
    FROM usuario u
    CROSS JOIN local l
    WHERE u.id_usuario = p_id_usuario
      AND l.id_local = p_id_local;

    SELECT COUNT(*)
    INTO v_tags_comuns
    FROM usuario_tag ut
    JOIN local_tag lt ON lt.id_tag = ut.id_tag
    WHERE ut.id_usuario = p_id_usuario
      AND lt.id_local = p_id_local;

    v_score := v_score + LEAST(30, v_tags_comuns * 10);

    IF v_prefere_premium = 'S' AND v_price_level >= 3 THEN
        v_contexto_score := v_contexto_score + 5;
    END IF;

    IF v_prefere_diurno = 'S' AND v_daytime = 'S' THEN
        v_contexto_score := v_contexto_score + 5;
    END IF;

    IF v_prefere_outdoor = 'S' AND v_indoor = 'N' THEN
        v_contexto_score := v_contexto_score + 5;
    END IF;

    SELECT COUNT(*)
    INTO v_tem_tag
    FROM local_tag lt
    JOIN tag t ON t.id_tag = lt.id_tag
    WHERE lt.id_local = p_id_local
      AND t.nome = 'social';

    IF v_prefere_social = 'S' AND v_tem_tag > 0 THEN
        v_contexto_score := v_contexto_score + 5;
    END IF;

    SELECT COUNT(*)
    INTO v_tem_tag
    FROM local_tag lt
    JOIN tag t ON t.id_tag = lt.id_tag
    WHERE lt.id_local = p_id_local
      AND t.nome = 'active';

    IF v_prefere_ativo = 'S' AND v_tem_tag > 0 THEN
        v_contexto_score := v_contexto_score + 5;
    END IF;

    SELECT COUNT(*)
    INTO v_tem_tag
    FROM local_tag lt
    JOIN tag t ON t.id_tag = lt.id_tag
    WHERE lt.id_local = p_id_local
      AND t.nome = 'new';

    IF v_prefere_novidade = 'S' AND v_tem_tag > 0 THEN
        v_contexto_score := v_contexto_score + 5;
    END IF;

    v_score := v_score + LEAST(25, v_contexto_score);

    SELECT COUNT(*)
    INTO v_positivas_categoria
    FROM interacao_usuario iu
    JOIN local l ON l.id_local = iu.id_local
    WHERE iu.id_usuario = p_id_usuario
      AND l.categoria = v_categoria
      AND iu.tipo_interacao IN ('CURTIU', 'SALVOU', 'VISITOU');

    SELECT COUNT(*)
    INTO v_ignoradas_categoria
    FROM interacao_usuario iu
    JOIN local l ON l.id_local = iu.id_local
    WHERE iu.id_usuario = p_id_usuario
      AND l.categoria = v_categoria
      AND iu.tipo_interacao = 'IGNOROU';

    v_historico_score := LEAST(20, v_positivas_categoria * 5);

    IF v_ignoradas_categoria > 0 THEN
        v_historico_score := GREATEST(0, v_historico_score - LEAST(5, v_ignoradas_categoria * 2));
    END IF;

    v_score := v_score + v_historico_score;

    SELECT COUNT(*)
    INTO v_positivas_local
    FROM interacao_usuario
    WHERE id_usuario = p_id_usuario
      AND id_local = p_id_local
      AND tipo_interacao IN ('CURTIU', 'SALVOU', 'VISITOU');

    v_direto_score := LEAST(10, v_positivas_local * 5);
    v_score := v_score + v_direto_score;

    SELECT NVL(AVG(a.nota), 0)
    INTO v_media_categoria
    FROM avaliacao a
    JOIN local l ON l.id_local = a.id_local
    WHERE a.id_usuario = p_id_usuario
      AND l.categoria = v_categoria;

    IF v_media_categoria > 0 THEN
        v_avaliacao_score := ROUND((v_media_categoria / 5) * 15);
    END IF;

    v_score := v_score + LEAST(15, v_avaliacao_score);

    RETURN LEAST(100, GREATEST(0, v_score));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN 0;
END fn_calcular_afinidade;
/

CREATE OR REPLACE FUNCTION fn_resumo_local (
    p_id_local IN NUMBER
) RETURN VARCHAR2
IS
    v_nome local.nome%TYPE;
    v_categoria local.categoria%TYPE;
    v_price_level local.price_level%TYPE;
    v_indoor local.indoor%TYPE;
    v_daytime local.daytime%TYPE;
    v_nightlife local.nightlife%TYPE;
    v_nota_media NUMBER;
    v_total_avaliacoes NUMBER;
    v_preco VARCHAR2(4);
    v_ambiente VARCHAR2(20);
    v_periodo VARCHAR2(20);
BEGIN
    SELECT
        l.nome,
        l.categoria,
        l.price_level,
        l.indoor,
        l.daytime,
        l.nightlife,
        NVL(ROUND(AVG(a.nota), 1), l.nota_media),
        COUNT(a.id_avaliacao)
    INTO
        v_nome,
        v_categoria,
        v_price_level,
        v_indoor,
        v_daytime,
        v_nightlife,
        v_nota_media,
        v_total_avaliacoes
    FROM local l
    LEFT JOIN avaliacao a ON a.id_local = l.id_local
    WHERE l.id_local = p_id_local
    GROUP BY
        l.nome,
        l.categoria,
        l.price_level,
        l.indoor,
        l.daytime,
        l.nightlife,
        l.nota_media;

    v_preco := RPAD('$', v_price_level, '$');
    v_ambiente := CASE WHEN v_indoor = 'S' THEN 'Indoor' ELSE 'Outdoor' END;
    v_periodo := CASE
        WHEN v_daytime = 'S' AND v_nightlife = 'S' THEN 'Diurno/Noturno'
        WHEN v_nightlife = 'S' THEN 'Noturno'
        ELSE 'Diurno'
    END;

    RETURN v_nome
        || ' | '
        || v_categoria
        || ' | Nota '
        || TO_CHAR(v_nota_media, 'FM990D0')
        || ' | '
        || v_preco
        || ' | '
        || v_ambiente
        || ' | '
        || v_periodo
        || ' | '
        || v_total_avaliacoes
        || CASE WHEN v_total_avaliacoes = 1 THEN ' avaliacao' ELSE ' avaliacoes' END;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Local nao encontrado';
    WHEN OTHERS THEN
        RETURN 'Resumo indisponivel';
END fn_resumo_local;
/

CREATE OR REPLACE FUNCTION fn_classificar_afinidade (
    p_score IN NUMBER
) RETURN VARCHAR2
IS
BEGIN
    IF p_score IS NULL THEN
        RETURN 'NAO_CALCULADA';
    ELSIF p_score < 0 OR p_score > 100 THEN
        RETURN 'INVALIDA';
    ELSIF p_score < 40 THEN
        RETURN 'BAIXA';
    ELSIF p_score < 70 THEN
        RETURN 'MEDIA';
    ELSE
        RETURN 'ALTA';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'INVALIDA';
END fn_classificar_afinidade;
/
