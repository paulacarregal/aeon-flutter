package com.aeon.backend.controller;

import com.aeon.backend.dto.InteractionRequest;
import com.aeon.backend.dto.InteractionResponse;
import com.aeon.backend.service.OracleRecommendationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/interactions")
public class InteractionController {

    private final OracleRecommendationService service;

    public InteractionController(OracleRecommendationService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public InteractionResponse create(
            @Valid @RequestBody InteractionRequest request
    ) {
        return service.registerInteraction(request);
    }
}

