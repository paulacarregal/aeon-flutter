package com.aeon.backend.dto;

import java.util.List;

public record RecommendationResponse(
        List<RecommendationItem> recommendations,
        String message
) {
}
