package com.aeon.backend.service;

import com.aeon.backend.dto.ReviewValidationRequest;
import com.aeon.backend.dto.ReviewValidationResponse;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class ReviewValidationServiceTest {

    private final ReviewValidationService service =
            new ReviewValidationService();

    @Test
    void validatesAndEnrichesKnownPlaceReview() {
        ReviewValidationResponse response = service.validate(
                new ReviewValidationRequest(
                        "user-123",
                        "bar-tan-tan",
                        "Bar Tan Tan",
                        "Endereco informado pelo app",
                        5,
                        " Muito bom ",
                        List.of("Ambiente", " drinks "),
                        " R$50-R$70 "
                )
        );

        assertThat(response.userId()).isEqualTo("user-123");
        assertThat(response.placeId()).isEqualTo("bar-tan-tan");
        assertThat(response.placeName()).isEqualTo("Bar Tan Tan");
        assertThat(response.address())
                .isEqualTo("Rua Fradique Coutinho, 153 - Pinheiros");
        assertThat(response.rating()).isEqualTo(5);
        assertThat(response.comment()).isEqualTo("Muito bom");
        assertThat(response.tags())
                .contains("ambiente", "drinks", "premium", "urban");
        assertThat(response.spendRange()).isEqualTo("R$50-R$70");
        assertThat(response.profileHints())
                .contains("Pioneiro Urbano", "Explorador Social");
        assertThat(response.reviewPrompts())
                .contains("drinks", "ambiente", "musica", "fila", "preco");
        assertThat(response.source()).isEqualTo("aeon-spring");
        assertThat(response.status()).isEqualTo("validated");
    }

    @Test
    void validatesUnknownPlaceWithoutCatalogEnrichment() {
        ReviewValidationResponse response = service.validate(
                new ReviewValidationRequest(
                        "user-123",
                        null,
                        "Novo Cafe",
                        "Rua Teste, 10",
                        4,
                        null,
                        List.of("Cafe", "Lugar calmo"),
                        null
                )
        );

        assertThat(response.placeId()).isEqualTo("novo-cafe");
        assertThat(response.placeName()).isEqualTo("Novo Cafe");
        assertThat(response.address()).isEqualTo("Rua Teste, 10");
        assertThat(response.comment()).isEmpty();
        assertThat(response.tags()).containsExactly("cafe", "lugar-calmo");
        assertThat(response.spendRange()).isNull();
        assertThat(response.profileHints()).isEmpty();
        assertThat(response.reviewPrompts()).isEmpty();
    }
}
