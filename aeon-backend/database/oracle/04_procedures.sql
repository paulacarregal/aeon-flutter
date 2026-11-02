CREATE OR REPLACE PROCEDURE pr_registrar_interacao (
    p_id_usuario IN NUMBER,
    p_id_local IN NUMBER,
    p_tipo_interacao IN VARCHAR2
)
IS
BEGIN
    pkg_aeon_recomendacao.pr_registrar_interacao(
        p_id_usuario,
        p_id_local,
        p_tipo_interacao
    );
END pr_registrar_interacao;
/

CREATE OR REPLACE PROCEDURE pr_gerar_recomendacoes (
    p_id_usuario IN NUMBER
)
IS
BEGIN
    pkg_aeon_recomendacao.pr_gerar_recomendacoes(p_id_usuario);
END pr_gerar_recomendacoes;
/

CREATE OR REPLACE PROCEDURE pr_atualizar_nota_media_local (
    p_id_local IN NUMBER
)
IS
BEGIN
    pkg_aeon_recomendacao.pr_atualizar_nota_media_local(p_id_local);
END pr_atualizar_nota_media_local;
/

CREATE OR REPLACE PROCEDURE pr_buscar_recomendacoes_dinamicas (
    p_id_usuario IN NUMBER,
    p_categoria IN VARCHAR2 DEFAULT NULL,
    p_somente_impulsionados IN CHAR DEFAULT 'N',
    p_nota_minima IN NUMBER DEFAULT NULL,
    p_ordem IN VARCHAR2 DEFAULT 'SCORE',
    p_resultado OUT SYS_REFCURSOR
)
IS
BEGIN
    pkg_aeon_recomendacao.pr_buscar_recomendacoes_dinamicas(
        p_id_usuario,
        p_categoria,
        p_somente_impulsionados,
        p_nota_minima,
        p_ordem,
        p_resultado
    );
END pr_buscar_recomendacoes_dinamicas;
/

CREATE OR REPLACE TRIGGER trg_avaliacao_atualiza_media
FOR INSERT OR UPDATE OR DELETE ON avaliacao
COMPOUND TRIGGER
    TYPE t_ids_local IS TABLE OF avaliacao.id_local%TYPE INDEX BY PLS_INTEGER;
    g_ids_local t_ids_local;

    PROCEDURE registrar_local (
        p_id_local IN avaliacao.id_local%TYPE
    )
    IS
    BEGIN
        IF p_id_local IS NOT NULL THEN
            g_ids_local(g_ids_local.COUNT + 1) := p_id_local;
        END IF;
    END registrar_local;

    AFTER EACH ROW IS
    BEGIN
        IF INSERTING THEN
            registrar_local(:NEW.id_local);
        ELSIF UPDATING THEN
            registrar_local(:OLD.id_local);
            registrar_local(:NEW.id_local);
        ELSIF DELETING THEN
            registrar_local(:OLD.id_local);
        END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
        v_processados VARCHAR2(4000) := '|';
        v_chave VARCHAR2(40);
    BEGIN
        IF g_ids_local.COUNT > 0 THEN
            FOR i IN 1 .. g_ids_local.COUNT LOOP
                v_chave := '|' || TO_CHAR(g_ids_local(i)) || '|';

                IF INSTR(v_processados, v_chave) = 0 THEN
                    pkg_aeon_recomendacao.pr_atualizar_nota_media_local(g_ids_local(i));
                    v_processados := v_processados || TO_CHAR(g_ids_local(i)) || '|';
                END IF;
            END LOOP;
        END IF;
    END AFTER STATEMENT;
END trg_avaliacao_atualiza_media;
/

CREATE OR REPLACE TRIGGER trg_audita_impulsionamento
AFTER INSERT OR UPDATE ON local_impulsionamento
FOR EACH ROW
DECLARE
    v_acao VARCHAR2(20);
    v_status_anterior local_impulsionamento.status%TYPE;
    v_peso_anterior local_impulsionamento.peso_bonus%TYPE;
BEGIN
    IF INSERTING THEN
        v_acao := 'INSERT';
        v_status_anterior := NULL;
        v_peso_anterior := NULL;
    ELSE
        v_acao := 'UPDATE';
        v_status_anterior := :OLD.status;
        v_peso_anterior := :OLD.peso_bonus;
    END IF;

    INSERT INTO auditoria_impulsionamento (
        id_impulsionamento,
        id_local,
        acao,
        status_anterior,
        status_novo,
        peso_anterior,
        peso_novo,
        data_evento
    ) VALUES (
        :NEW.id_impulsionamento,
        :NEW.id_local,
        v_acao,
        v_status_anterior,
        :NEW.status,
        v_peso_anterior,
        :NEW.peso_bonus,
        SYSTIMESTAMP
    );
END trg_audita_impulsionamento;
/
