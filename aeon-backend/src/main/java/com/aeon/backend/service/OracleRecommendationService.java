package com.aeon.backend.service;

import com.aeon.backend.dto.InteractionRequest;
import com.aeon.backend.dto.InteractionResponse;
import com.aeon.backend.dto.RecommendationResponse;
import com.aeon.backend.exception.ResourceNotFoundException;
import com.aeon.backend.repository.OracleRecommendationRepository;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;

@Service
public class OracleRecommendationService {

    private final OracleRecommendationRepository repository;

    public OracleRecommendationService(
            OracleRecommendationRepository repository
    ) {
        this.repository = repository;
    }

    public InteractionResponse registerInteraction(
            InteractionRequest request
    ) {
        String interactionType = normalizeInteractionType(
                request.tipoInteracao()
        );

        try {
            Long userId = repository
                    .findUserIdByFirebaseUid(request.firebaseUid())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Usuario Oracle nao encontrado para o Firebase UID."
                    ));

            repository.registerInteraction(
                    userId,
                    request.localId(),
                    interactionType
            );

            return new InteractionResponse(
                    request.firebaseUid(),
                    request.localId(),
                    interactionType,
                    "INTERACAO_REGISTRADA"
            );
        } catch (DataAccessException e) {
            throw new IllegalStateException(
                    "Erro ao registrar interacao no Oracle.",
                    e
            );
        }
    }

    public List<RecommendationResponse> findRecommendations(
            String firebaseUid
    ) {
        try {
            Long userId = repository
                    .findUserIdByFirebaseUid(firebaseUid)
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Usuario Oracle nao encontrado para o Firebase UID."
                    ));

            repository.generateRecommendations(userId);
            return repository.findRecommendationsByFirebaseUid(firebaseUid);
        } catch (DataAccessException e) {
            throw new IllegalStateException(
                    "Erro ao consultar recomendacoes no Oracle.",
                    e
            );
        }
    }

    private static String normalizeInteractionType(String interactionType) {
        String normalized = interactionType
                .trim()
                .toUpperCase(Locale.ROOT);

        if (!List.of(
                "VISUALIZOU",
                "CURTIU",
                "SALVOU",
                "VISITOU",
                "IGNOROU"
        ).contains(normalized)) {
            throw new IllegalArgumentException(
                    "tipoInteracao deve ser VISUALIZOU, CURTIU, SALVOU, VISITOU ou IGNOROU."
            );
        }

        return normalized;
    }
}
