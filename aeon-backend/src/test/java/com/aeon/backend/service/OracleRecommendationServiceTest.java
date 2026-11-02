package com.aeon.backend.service;

import com.aeon.backend.dto.InteractionRequest;
import com.aeon.backend.dto.InteractionResponse;
import com.aeon.backend.dto.RecommendationResponse;
import com.aeon.backend.exception.ResourceNotFoundException;
import com.aeon.backend.repository.OracleRecommendationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataAccessResourceFailureException;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class OracleRecommendationServiceTest {

    private OracleRecommendationRepository repository;
    private OracleRecommendationService service;

    @BeforeEach
    void setUp() {
        repository = mock(OracleRecommendationRepository.class);
        service = new OracleRecommendationService(repository);
    }

    @Test
    void registersNormalizedInteractionForExistingUser() {
        when(repository.findUserIdByFirebaseUid("uid-demo-blair"))
                .thenReturn(Optional.of(1L));

        InteractionResponse response = service.registerInteraction(
                new InteractionRequest("uid-demo-blair", 3L, " salvou ")
        );

        assertThat(response.tipoInteracao()).isEqualTo("SALVOU");
        assertThat(response.status()).isEqualTo("INTERACAO_REGISTRADA");
        verify(repository).registerInteraction(1L, 3L, "SALVOU");
    }

    @Test
    void rejectsUnsupportedInteractionTypeBeforeAccessingOracle() {
        InteractionRequest request = new InteractionRequest(
                "uid-demo-blair",
                1L,
                "COMPARTILHOU"
        );

        assertThatThrownBy(() -> service.registerInteraction(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("tipoInteracao deve ser");

        verify(repository, never()).findUserIdByFirebaseUid("uid-demo-blair");
    }

    @Test
    void reportsMissingOracleUser() {
        when(repository.findUserIdByFirebaseUid("uid-inexistente"))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.findRecommendations("uid-inexistente"))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("Usuario Oracle nao encontrado");
    }

    @Test
    void generatesAndReturnsRecommendations() {
        RecommendationResponse recommendation = new RecommendationResponse(
                4L,
                "Parque Verde",
                "Outdoor",
                "Av. Verde, 120 - Sao Paulo",
                4.8,
                80.0,
                "Parque Verde | Outdoor",
                "2026-11-02T10:00:00Z"
        );

        when(repository.findUserIdByFirebaseUid("uid-demo-ken"))
                .thenReturn(Optional.of(2L));
        when(repository.findRecommendationsByFirebaseUid("uid-demo-ken"))
                .thenReturn(List.of(recommendation));

        List<RecommendationResponse> result =
                service.findRecommendations("uid-demo-ken");

        assertThat(result).containsExactly(recommendation);
        verify(repository).generateRecommendations(2L);
    }

    @Test
    void convertsDatabaseFailureIntoIntegrationError() {
        when(repository.findUserIdByFirebaseUid("uid-demo-ken"))
                .thenThrow(new DataAccessResourceFailureException("offline"));

        assertThatThrownBy(() -> service.findRecommendations("uid-demo-ken"))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Erro ao consultar recomendacoes no Oracle.")
                .hasCauseInstanceOf(DataAccessResourceFailureException.class);
    }
}
