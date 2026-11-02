package com.aeon.backend.database;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;

import static org.assertj.core.api.Assertions.assertThat;

class OracleSqlArtifactsTest {

    private static final Path ORACLE_DIR = Path.of("database", "oracle");

    @Test
    void packageContainsRecommendationApiAndDynamicSql() throws IOException {
        String sql = readUppercase("03_functions.sql");

        assertThat(sql)
                .contains("CREATE OR REPLACE PACKAGE PKG_AEON_RECOMENDACAO")
                .contains("FN_CALCULAR_BONUS_PROXIMIDADE")
                .contains("FN_CALCULAR_BONUS_IMPULSIONAMENTO")
                .contains("FN_CALCULAR_SCORE_FINAL")
                .contains("PR_BUSCAR_RECOMENDACOES_DINAMICAS")
                .contains("OUT SYS_REFCURSOR")
                .contains("OPEN P_RESULTADO FOR V_SQL");
    }

    @Test
    void automationAndAuditTriggersAreDeclared() throws IOException {
        String sql = readUppercase("04_procedures.sql");

        assertThat(sql)
                .contains("TRG_AVALIACAO_ATUALIZA_MEDIA")
                .contains("TRG_AUDITA_IMPULSIONAMENTO")
                .contains("FOR INSERT OR UPDATE OR DELETE ON AVALIACAO")
                .contains("AFTER INSERT OR UPDATE ON LOCAL_IMPULSIONAMENTO");
    }

    @Test
    void incrementalDeploymentCreatesCommercialTablesSafely()
            throws IOException {
        String sql = readUppercase("06_devops_upgrade.sql");

        assertThat(sql)
                .contains("LOCAL_IMPULSIONAMENTO")
                .contains("AUDITORIA_IMPULSIONAMENTO")
                .contains("AUDITORIA_RECOMENDACAO")
                .contains("EXECUTE IMMEDIATE")
                .contains("USER_TABLES");
    }

    private static String readUppercase(String fileName) throws IOException {
        return Files.readString(ORACLE_DIR.resolve(fileName))
                .toUpperCase(Locale.ROOT);
    }
}
