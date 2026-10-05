package com.aeon.backend.controller;

import com.aeon.backend.dto.RecommendationResponse;
import com.aeon.backend.service.OracleRecommendationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/recommendations")
public class RecommendationController {

    private final OracleRecommendationService service;

    public RecommendationController(OracleRecommendationService service) {
        this.service = service;
    }

    @GetMapping("/{firebaseUid}")
    public List<RecommendationResponse> findByFirebaseUid(
            @PathVariable String firebaseUid
    ) {
        return service.findRecommendations(firebaseUid);
    }
}

