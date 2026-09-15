package com.aeon.backend.dto;

import java.util.List;

public record ReviewPromptsResponse(
        String placeId,
        String name,
        List<String> profileHints,
        List<String> reviewPrompts,
        List<String> tags
) {
}
