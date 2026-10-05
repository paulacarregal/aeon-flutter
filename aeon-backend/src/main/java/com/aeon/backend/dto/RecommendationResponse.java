package com.aeon.backend.dto;

public record RecommendationResponse(
        Long localId,
        String nome,
        String categoria,
        String endereco,
        Double notaMedia,
        Double score,
        String resumo,
        String dataRecomendacao
) {
}

