package com.aeon.backend.dto;

import java.util.List;

public record ReviewValidationResponse(
        String userId,
        String placeId,
        String placeName,
        String address,
        int rating,
        String comment,
        List<String> tags,
        String spendRange,
        List<String> profileHints,
        List<String> reviewPrompts,
        String source,
        String status
) {
}
