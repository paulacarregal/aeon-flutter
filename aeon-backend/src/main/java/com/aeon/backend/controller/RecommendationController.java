package com.aeon.backend.controller;

import com.aeon.backend.dto.NotificationContextRequest;
import com.aeon.backend.dto.NotificationContextResponse;
import com.aeon.backend.dto.RecommendationResponse;
import com.aeon.backend.dto.RecommendPlacesRequest;
import com.aeon.backend.service.RecommendationService;
import org.springframework.web.bind.annotation.*;

@RestController
public class RecommendationController {

    private final RecommendationService recommendationService;

    public RecommendationController(
            RecommendationService recommendationService
    ) {
        this.recommendationService = recommendationService;
    }

    @PostMapping("/recommend-places")
    public RecommendationResponse recommendPlaces(
            @RequestBody RecommendPlacesRequest payload
    ) {
        return recommendationService.recommendPlaces(payload);
    }

    @PostMapping("/recommendPlaces")
    public RecommendationResponse recommendPlacesAlias(
            @RequestBody RecommendPlacesRequest payload
    ) {
        return recommendationService.recommendPlaces(payload);
    }

    @PostMapping("/notification-context")
    public NotificationContextResponse notificationContext(
            @RequestBody NotificationContextRequest payload
    ) {
        return recommendationService.notificationContext(payload);
    }

    @PostMapping("/notificationContext")
    public NotificationContextResponse notificationContextAlias(
            @RequestBody NotificationContextRequest payload
    ) {
        return recommendationService.notificationContext(payload);
    }
}
