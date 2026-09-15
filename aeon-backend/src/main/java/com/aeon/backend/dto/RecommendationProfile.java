package com.aeon.backend.dto;

import java.util.List;

public record RecommendationProfile(
        String name,
        List<String> preferredTags
) {
}
