package com.aeon.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record InteractionRequest(
        @NotBlank(message = "firebaseUid e obrigatorio.")
        String firebaseUid,

        @NotNull(message = "localId e obrigatorio.")
        @Positive(message = "localId deve ser positivo.")
        Long localId,

        @NotBlank(message = "tipoInteracao e obrigatorio.")
        String tipoInteracao
) {
}

