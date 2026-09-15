package com.aeon.backend.dto;

public record DeviceContext(
        Double latitude,
        Double longitude,
        String weatherDescription,
        Double temperature,
        String transportMode
) {
}
