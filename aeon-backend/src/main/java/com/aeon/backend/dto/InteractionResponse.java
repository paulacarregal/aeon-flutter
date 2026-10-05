package com.aeon.backend.dto;

public record InteractionResponse(
        String firebaseUid,
        Long localId,
        String tipoInteracao,
        String status
) {
}

