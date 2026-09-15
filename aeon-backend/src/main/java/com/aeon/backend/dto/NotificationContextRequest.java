package com.aeon.backend.dto;

public record NotificationContextRequest(
        RecommendationProfile profile,
        DeviceContext device
) {
}
