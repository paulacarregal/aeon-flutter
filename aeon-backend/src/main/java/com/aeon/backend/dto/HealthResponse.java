package com.aeon.backend.dto;

public record HealthResponse(
        String status,
        String service,
        String version
) {
}
