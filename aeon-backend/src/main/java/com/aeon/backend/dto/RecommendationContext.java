package com.aeon.backend.dto;

public record RecommendationContext(
        boolean raining,
        boolean night,
        Double maxDistanceMeters,
        String transportMode
) {
}
