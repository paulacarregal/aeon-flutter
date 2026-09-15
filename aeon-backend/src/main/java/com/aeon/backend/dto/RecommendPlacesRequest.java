package com.aeon.backend.dto;

import java.util.List;

public record RecommendPlacesRequest(
        RecommendationProfile profile,
        List<PlaceCandidate> places,
        RecommendationContext context
) {
}
