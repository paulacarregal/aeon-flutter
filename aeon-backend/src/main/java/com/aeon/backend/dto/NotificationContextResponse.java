package com.aeon.backend.dto;

import java.util.List;
import java.util.Map;

public record NotificationContextResponse(
        NotificationResponse notification,
        Map<String, Object> selected,
        List<Map<String, Object>> alternatives,
        RecommendationContext context
) {
}
