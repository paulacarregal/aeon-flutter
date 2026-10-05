package com.aeon.backend.repository;

import com.aeon.backend.dto.RecommendationResponse;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.ConnectionCallback;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.CallableStatement;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@Repository
public class OracleRecommendationRepository {

    private final JdbcTemplate jdbcTemplate;

    public OracleRecommendationRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Optional<Long> findUserIdByFirebaseUid(String firebaseUid) {
        try {
            Long id = jdbcTemplate.queryForObject(
                    """
                    SELECT id_usuario
                    FROM usuario
                    WHERE firebase_uid = ?
                    """,
                    Long.class,
                    firebaseUid
            );

            return Optional.ofNullable(id);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public void registerInteraction(
            Long userId,
            Long localId,
            String interactionType
    ) {
        jdbcTemplate.execute((ConnectionCallback<Void>) connection -> {
            try (CallableStatement statement = connection.prepareCall(
                    "{call pr_registrar_interacao(?, ?, ?)}"
            )) {
                statement.setLong(1, userId);
                statement.setLong(2, localId);
                statement.setString(3, interactionType);
                statement.execute();
            }

            return null;
        });
    }

    public void generateRecommendations(Long userId) {
        jdbcTemplate.execute((ConnectionCallback<Void>) connection -> {
            try (CallableStatement statement = connection.prepareCall(
                    "{call pr_gerar_recomendacoes(?)}"
            )) {
                statement.setLong(1, userId);
                statement.execute();
            }

            return null;
        });
    }

    public List<RecommendationResponse> findRecommendationsByFirebaseUid(
            String firebaseUid
    ) {
        return jdbcTemplate.query(
                """
                SELECT
                    l.id_local,
                    l.nome,
                    l.categoria,
                    l.endereco,
                    l.nota_media,
                    h.score,
                    fn_resumo_local(l.id_local) AS resumo,
                    h.data_recomendacao
                FROM historico_recomendacao h
                JOIN usuario u ON u.id_usuario = h.id_usuario
                JOIN local l ON l.id_local = h.id_local
                WHERE u.firebase_uid = ?
                ORDER BY h.score DESC, h.data_recomendacao DESC
                """,
                (resultSet, rowNum) -> new RecommendationResponse(
                        resultSet.getLong("id_local"),
                        resultSet.getString("nome"),
                        resultSet.getString("categoria"),
                        resultSet.getString("endereco"),
                        resultSet.getDouble("nota_media"),
                        resultSet.getDouble("score"),
                        resultSet.getString("resumo"),
                        formatTimestamp(
                                resultSet.getTimestamp("data_recomendacao")
                        )
                ),
                firebaseUid
        );
    }

    private static String formatTimestamp(Timestamp timestamp) {
        if (timestamp == null) {
            return "";
        }

        return timestamp.toInstant().toString();
    }
}

