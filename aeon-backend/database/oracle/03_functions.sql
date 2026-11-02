CREATE OR REPLACE PACKAGE pkg_aeon_recomendacao AS
    FUNCTION fn_calcular_afinidade (
        p_id_usuario IN NUMBER,
        p_id_local IN NUMBER
    ) RETURN NUMBER;

    FUNCTION fn_resumo_local (
        p_id_local IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION fn_classificar_afinidade (
        p_score IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION fn_calcular_bonus_proximidade (
        p_id_usuario IN NUMBER,
        p_id_local IN NUMBER
    ) RETURN NUMBER;

    FUNCTION fn_calcular_bonus_impulsionamento (
        p_id_usuario IN NUMBER,
        p_id_local IN NUMBER
    ) RETURN NUMBER;

    FUNCTION fn_calcular_score_final (
        p_id_usuario IN NUMBER,
        p_id_local IN NUMBER
    ) RETURN NUMBER;

    PROCEDURE pr_registrar_interacao (
        p_id_usuario IN NUMBER,
        p_id_local IN NUMBER,
        p_tipo_interacao IN VARCHAR2
    );

    PROCEDURE pr_gerar_recomendacoes (
        p_id_usuario IN NUMBER
    );

    PROCEDURE pr_atualizar_nota_media_local (
        p_id_local IN NUMBER
    );

    PROCEDURE pr_buscar_recomendacoes_dinamicas (
        p_id_usuario IN NUMBER,
        p_categoria IN VARCHAR2 DEFAULT NULL,
        p_somente_impulsionados IN CHAR DEFAULT 'N',
        p_nota_minima IN NUMBER DEFAULT NULL,
        p_ordem IN VARCHAR2 DEFAULT 'SCORE',
        p_resultado OUT SYS_REFCURSOR
    );
END pkg_aeon_recomendacao;
/

CREATE OR REPLACE PACKAGE BODY pkg_aeon_recomendacao AS
    FUNCTION normalizar_score (
        p_score IN NUMBER
    ) RETURN NUMBER
    IS
    BEGIN
        RETURN LEAST(100, GREATEST(0, NVL(p_score, 0)));
    END normalizar_score;

    FUNCTION fn_calcular_afinidade (
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

        RETURN normalizar_score(v_score);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END fn_calcular_afinidade;

    FUNCTION fn_resumo_local (
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

    FUNCTION fn_classificar_afinidade (
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

    FUNCTION fn_calcular_bonus_proximidade (
        p_id_usuario IN NUMBER,
        p_id_local IN NUMBER
    ) RETURN NUMBER
    IS
        v_lat_candidato local.latitude%TYPE;
        v_long_candidato local.longitude%TYPE;
        v_bonus NUMBER := 0;
        v_distancia_km NUMBER;
    BEGIN
        SELECT latitude, longitude
        INTO v_lat_candidato, v_long_candidato
        FROM local
        WHERE id_local = p_id_local
          AND ativo = 'S';

        FOR r_local IN (
            SELECT id_local, latitude, longitude
            FROM local
            WHERE ativo = 'S'
              AND id_local <> p_id_local
        ) LOOP
            IF fn_calcular_afinidade(p_id_usuario, r_local.id_local) >= 70 THEN
                v_distancia_km := SQRT(
                    POWER((v_lat_candidato - r_local.latitude) * 111, 2)
                    + POWER((v_long_candidato - r_local.longitude) * 111, 2)
                );

                IF v_distancia_km <= 1 THEN
                    v_bonus := GREATEST(v_bonus, 10);
                ELSIF v_distancia_km <= 3 THEN
                    v_bonus := GREATEST(v_bonus, 7);
                ELSIF v_distancia_km <= 5 THEN
                    v_bonus := GREATEST(v_bonus, 4);
                END IF;
            END IF;
        END LOOP;

        RETURN LEAST(12, v_bonus);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END fn_calcular_bonus_proximidade;

    FUNCTION fn_calcular_bonus_impulsionamento (
        p_id_usuario IN NUMBER,
        p_id_local IN NUMBER
    ) RETURN NUMBER
    IS
        v_local_ativo local.ativo%TYPE;
        v_nota_media local.nota_media%TYPE;
        v_afinidade NUMBER;
        v_bonus_proximidade NUMBER;
        v_bonus NUMBER := 0;
    BEGIN
        SELECT ativo, nota_media
        INTO v_local_ativo, v_nota_media
        FROM local
        WHERE id_local = p_id_local;

        IF v_local_ativo <> 'S' THEN
            RETURN 0;
        END IF;

        v_afinidade := fn_calcular_afinidade(p_id_usuario, p_id_local);
        v_bonus_proximidade := fn_calcular_bonus_proximidade(p_id_usuario, p_id_local);

        IF v_nota_media < 4
           AND v_afinidade < 40
           AND v_bonus_proximidade = 0 THEN
            RETURN 0;
        END IF;

        SELECT NVL(MAX(LEAST(peso_bonus, 12)), 0)
        INTO v_bonus
        FROM local_impulsionamento
        WHERE id_local = p_id_local
          AND status = 'ATIVO'
          AND TRUNC(SYSDATE) BETWEEN data_inicio AND data_fim;

        RETURN LEAST(12, v_bonus);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END fn_calcular_bonus_impulsionamento;

    FUNCTION fn_calcular_score_final (
        p_id_usuario IN NUMBER,
        p_id_local IN NUMBER
    ) RETURN NUMBER
    IS
        v_afinidade NUMBER;
        v_bonus_proximidade NUMBER;
        v_bonus_impulsionamento NUMBER;
    BEGIN
        v_afinidade := fn_calcular_afinidade(p_id_usuario, p_id_local);
        v_bonus_proximidade := fn_calcular_bonus_proximidade(p_id_usuario, p_id_local);
        v_bonus_impulsionamento := fn_calcular_bonus_impulsionamento(p_id_usuario, p_id_local);

        RETURN normalizar_score(v_afinidade + v_bonus_proximidade + v_bonus_impulsionamento);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END fn_calcular_score_final;

    PROCEDURE pr_registrar_interacao (
        p_id_usuario IN NUMBER,
        p_id_local IN NUMBER,
        p_tipo_interacao IN VARCHAR2
    )
    IS
        v_usuario_count NUMBER;
        v_local_count NUMBER;
        v_tipo_interacao VARCHAR2(20);
    BEGIN
        v_tipo_interacao := UPPER(TRIM(p_tipo_interacao));

        SELECT COUNT(*)
        INTO v_usuario_count
        FROM usuario
        WHERE id_usuario = p_id_usuario;

        IF v_usuario_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Usuario nao encontrado.');
        END IF;

        SELECT COUNT(*)
        INTO v_local_count
        FROM local
        WHERE id_local = p_id_local
          AND ativo = 'S';

        IF v_local_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Local nao encontrado ou inativo.');
        END IF;

        IF v_tipo_interacao NOT IN (
            'VISUALIZOU',
            'CURTIU',
            'SALVOU',
            'VISITOU',
            'IGNOROU'
        ) THEN
            RAISE_APPLICATION_ERROR(-20003, 'Tipo de interacao invalido.');
        END IF;

        INSERT INTO interacao_usuario (
            id_usuario,
            id_local,
            tipo_interacao,
            data_interacao
        ) VALUES (
            p_id_usuario,
            p_id_local,
            v_tipo_interacao,
            SYSTIMESTAMP
        );
    END pr_registrar_interacao;

    PROCEDURE pr_gerar_recomendacoes (
        p_id_usuario IN NUMBER
    )
    IS
        CURSOR c_locais_ativos IS
            SELECT id_local
            FROM local
            WHERE ativo = 'S';

        v_usuario_count NUMBER;
        v_afinidade NUMBER;
        v_bonus_proximidade NUMBER;
        v_bonus_impulsionamento NUMBER;
        v_score_final NUMBER;
        v_tipo_recomendacao VARCHAR2(40);
        v_justificativa VARCHAR2(500);
        v_score_minimo CONSTANT NUMBER := 55;
    BEGIN
        SELECT COUNT(*)
        INTO v_usuario_count
        FROM usuario
        WHERE id_usuario = p_id_usuario;

        IF v_usuario_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Usuario nao encontrado.');
        END IF;

        FOR r_local IN c_locais_ativos LOOP
            v_afinidade := fn_calcular_afinidade(p_id_usuario, r_local.id_local);
            v_bonus_proximidade := fn_calcular_bonus_proximidade(p_id_usuario, r_local.id_local);
            v_bonus_impulsionamento := fn_calcular_bonus_impulsionamento(p_id_usuario, r_local.id_local);
            v_score_final := normalizar_score(v_afinidade + v_bonus_proximidade + v_bonus_impulsionamento);

            IF v_bonus_impulsionamento > 0 AND v_bonus_proximidade > 0 THEN
                v_tipo_recomendacao := 'COMPLEMENTAR_IMPULSIONADA';
            ELSIF v_bonus_impulsionamento > 0 THEN
                v_tipo_recomendacao := 'IMPULSIONADA';
            ELSIF v_bonus_proximidade > 0 AND v_afinidade < 70 THEN
                v_tipo_recomendacao := 'COMPLEMENTAR';
            ELSE
                v_tipo_recomendacao := 'PRINCIPAL';
            END IF;

            v_justificativa := 'Afinidade direta '
                || TO_CHAR(v_afinidade, 'FM990D00')
                || ', proximidade '
                || TO_CHAR(v_bonus_proximidade, 'FM990D00')
                || ', impulsionamento '
                || TO_CHAR(v_bonus_impulsionamento, 'FM990D00');

            INSERT INTO auditoria_recomendacao (
                id_usuario,
                id_local,
                tipo_recomendacao,
                score_afinidade,
                bonus_proximidade,
                bonus_impulsionamento,
                score_final,
                justificativa,
                data_evento
            ) VALUES (
                p_id_usuario,
                r_local.id_local,
                v_tipo_recomendacao,
                v_afinidade,
                v_bonus_proximidade,
                v_bonus_impulsionamento,
                v_score_final,
                v_justificativa,
                SYSTIMESTAMP
            );

            IF v_score_final >= v_score_minimo THEN
                MERGE INTO historico_recomendacao h
                USING (
                    SELECT
                        p_id_usuario AS id_usuario,
                        r_local.id_local AS id_local,
                        v_score_final AS score
                    FROM dual
                ) origem
                ON (
                    h.id_usuario = origem.id_usuario
                    AND h.id_local = origem.id_local
                )
                WHEN MATCHED THEN
                    UPDATE SET
                        h.score = origem.score,
                        h.data_recomendacao = SYSTIMESTAMP
                WHEN NOT MATCHED THEN
                    INSERT (
                        id_usuario,
                        id_local,
                        score,
                        data_recomendacao
                    ) VALUES (
                        origem.id_usuario,
                        origem.id_local,
                        origem.score,
                        SYSTIMESTAMP
                    );
            END IF;
        END LOOP;

        DELETE FROM historico_recomendacao h
        WHERE h.id_usuario = p_id_usuario
          AND (
              NOT EXISTS (
                  SELECT 1
                  FROM local l
                  WHERE l.id_local = h.id_local
                    AND l.ativo = 'S'
              )
              OR fn_calcular_score_final(p_id_usuario, h.id_local) < v_score_minimo
          );
    END pr_gerar_recomendacoes;

    PROCEDURE pr_atualizar_nota_media_local (
        p_id_local IN NUMBER
    )
    IS
        v_local_count NUMBER;
        v_media NUMBER(3, 2);
    BEGIN
        SELECT COUNT(*)
        INTO v_local_count
        FROM local
        WHERE id_local = p_id_local;

        IF v_local_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Local nao encontrado.');
        END IF;

        SELECT ROUND(NVL(AVG(nota), 0), 2)
        INTO v_media
        FROM avaliacao
        WHERE id_local = p_id_local;

        UPDATE local
        SET nota_media = v_media
        WHERE id_local = p_id_local;
    END pr_atualizar_nota_media_local;

    PROCEDURE pr_buscar_recomendacoes_dinamicas (
        p_id_usuario IN NUMBER,
        p_categoria IN VARCHAR2,
        p_somente_impulsionados IN CHAR,
        p_nota_minima IN NUMBER,
        p_ordem IN VARCHAR2,
        p_resultado OUT SYS_REFCURSOR
    )
    IS
        v_sql VARCHAR2(4000);
        v_ordem VARCHAR2(20);
        v_somente_impulsionados CHAR(1);
    BEGIN
        v_ordem := UPPER(TRIM(NVL(p_ordem, 'SCORE')));
        v_somente_impulsionados := UPPER(TRIM(NVL(p_somente_impulsionados, 'N')));

        IF v_ordem NOT IN ('SCORE', 'NOTA', 'NOME') THEN
            RAISE_APPLICATION_ERROR(-20031, 'Ordenacao dinamica invalida.');
        END IF;

        IF v_somente_impulsionados NOT IN ('S', 'N') THEN
            RAISE_APPLICATION_ERROR(-20032, 'Filtro de impulsionamento invalido.');
        END IF;

        v_sql := '
            SELECT
                l.id_local,
                l.nome,
                l.categoria,
                l.nota_media,
                pkg_aeon_recomendacao.fn_calcular_afinidade(:id_usuario, l.id_local) AS score_afinidade,
                pkg_aeon_recomendacao.fn_calcular_bonus_proximidade(:id_usuario, l.id_local) AS bonus_proximidade,
                pkg_aeon_recomendacao.fn_calcular_bonus_impulsionamento(:id_usuario, l.id_local) AS bonus_impulsionamento,
                pkg_aeon_recomendacao.fn_calcular_score_final(:id_usuario, l.id_local) AS score_final
            FROM local l
            WHERE l.ativo = ''S''
              AND (:categoria IS NULL OR l.categoria = :categoria)
              AND (:nota_minima IS NULL OR l.nota_media >= :nota_minima)';

        IF v_somente_impulsionados = 'S' THEN
            v_sql := v_sql || '
              AND EXISTS (
                  SELECT 1
                  FROM local_impulsionamento li
                  WHERE li.id_local = l.id_local
                    AND li.status = ''ATIVO''
                    AND TRUNC(SYSDATE) BETWEEN li.data_inicio AND li.data_fim
              )';
        END IF;

        IF v_ordem = 'NOTA' THEN
            v_sql := v_sql || ' ORDER BY l.nota_media DESC, score_final DESC, l.nome';
        ELSIF v_ordem = 'NOME' THEN
            v_sql := v_sql || ' ORDER BY l.nome ASC';
        ELSE
            v_sql := v_sql || ' ORDER BY score_final DESC, l.nota_media DESC, l.nome';
        END IF;

        OPEN p_resultado FOR v_sql
            USING p_id_usuario,
                  p_id_usuario,
                  p_id_usuario,
                  p_id_usuario,
                  p_categoria,
                  p_categoria,
                  p_nota_minima,
                  p_nota_minima;
    END pr_buscar_recomendacoes_dinamicas;
END pkg_aeon_recomendacao;
/

CREATE OR REPLACE FUNCTION fn_calcular_afinidade (
    p_id_usuario IN NUMBER,
    p_id_local IN NUMBER
) RETURN NUMBER
IS
BEGIN
    RETURN pkg_aeon_recomendacao.fn_calcular_afinidade(
        p_id_usuario,
        p_id_local
    );
END fn_calcular_afinidade;
/

CREATE OR REPLACE FUNCTION fn_resumo_local (
    p_id_local IN NUMBER
) RETURN VARCHAR2
IS
BEGIN
    RETURN pkg_aeon_recomendacao.fn_resumo_local(p_id_local);
END fn_resumo_local;
/

CREATE OR REPLACE FUNCTION fn_classificar_afinidade (
    p_score IN NUMBER
) RETURN VARCHAR2
IS
BEGIN
    RETURN pkg_aeon_recomendacao.fn_classificar_afinidade(p_score);
END fn_classificar_afinidade;
/
