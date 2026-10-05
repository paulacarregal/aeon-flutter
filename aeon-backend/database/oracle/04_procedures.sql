CREATE OR REPLACE PROCEDURE pr_registrar_interacao (
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
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END pr_registrar_interacao;
/

CREATE OR REPLACE PROCEDURE pr_gerar_recomendacoes (
    p_id_usuario IN NUMBER
)
IS
    CURSOR c_locais_ativos IS
        SELECT id_local
        FROM local
        WHERE ativo = 'S';

    v_usuario_count NUMBER;
    v_score NUMBER;
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
        v_score := fn_calcular_afinidade(p_id_usuario, r_local.id_local);

        IF v_score >= v_score_minimo THEN
            MERGE INTO historico_recomendacao h
            USING (
                SELECT
                    p_id_usuario AS id_usuario,
                    r_local.id_local AS id_local,
                    v_score AS score
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
          OR fn_calcular_afinidade(p_id_usuario, h.id_local) < v_score_minimo
      );
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END pr_gerar_recomendacoes;
/

CREATE OR REPLACE PROCEDURE pr_atualizar_nota_media_local (
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
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END pr_atualizar_nota_media_local;
/
