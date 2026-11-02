SET SERVEROUTPUT ON

DECLARE
    v_missing NUMBER;
    v_invalid NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_missing
    FROM (
        SELECT 'PKG_AEON_RECOMENDACAO' AS object_name FROM dual
        UNION ALL SELECT 'FN_CALCULAR_AFINIDADE' FROM dual
        UNION ALL SELECT 'FN_RESUMO_LOCAL' FROM dual
        UNION ALL SELECT 'FN_CLASSIFICAR_AFINIDADE' FROM dual
        UNION ALL SELECT 'PR_REGISTRAR_INTERACAO' FROM dual
        UNION ALL SELECT 'PR_GERAR_RECOMENDACOES' FROM dual
        UNION ALL SELECT 'PR_ATUALIZAR_NOTA_MEDIA_LOCAL' FROM dual
        UNION ALL SELECT 'PR_BUSCAR_RECOMENDACOES_DINAMICAS' FROM dual
        UNION ALL SELECT 'TRG_AVALIACAO_ATUALIZA_MEDIA' FROM dual
        UNION ALL SELECT 'TRG_AUDITA_IMPULSIONAMENTO' FROM dual
    ) required_objects
    WHERE NOT EXISTS (
        SELECT 1
        FROM all_objects existing_objects
        WHERE existing_objects.owner = SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
          AND existing_objects.object_name = required_objects.object_name
    );

    SELECT COUNT(*)
    INTO v_invalid
    FROM all_objects
    WHERE owner = SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
      AND object_name IN (
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
      AND status <> 'VALID';

    IF v_missing > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20101,
            'Deploy incompleto: existem objetos Oracle ausentes.'
        );
    END IF;

    IF v_invalid > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20102,
            'Deploy invalido: existem objetos Oracle com erro de compilacao.'
        );
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        'Deploy Oracle validado: package, wrappers e triggers estao VALID.'
    );
END;
/

SELECT object_name, object_type, status
FROM all_objects
WHERE owner = SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
  AND object_name IN (
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
