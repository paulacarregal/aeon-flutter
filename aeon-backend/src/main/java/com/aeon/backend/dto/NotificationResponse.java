package com.aeon.backend.dto;

public record NotificationResponse(
        String title,
        String body,
        String type,
        String placeId,
        Double latitude,
        Double longitude
) {
}
