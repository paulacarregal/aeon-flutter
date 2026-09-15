package com.aeon.backend.dto;

public record RecommendationItem(
        String id,
        String name,
        double rating,
        java.util.List<String> tags,
        boolean indoor,
        Double distanceMeters,
        int score
) {
}
