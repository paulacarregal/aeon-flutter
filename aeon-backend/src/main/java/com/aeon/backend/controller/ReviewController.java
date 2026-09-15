package com.aeon.backend.controller;

import com.aeon.backend.dto.ReviewValidationRequest;
import com.aeon.backend.dto.ReviewValidationResponse;
import com.aeon.backend.service.ReviewService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/reviews")
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(
            ReviewService reviewService
    ) {
        this.reviewService = reviewService;
    }

    @PostMapping("/validate")
    public ReviewValidationResponse validateReview(
            @Valid @RequestBody ReviewValidationRequest payload
    ) {
        return reviewService.validateReview(payload);
    }

    @PostMapping("/validate-and-enrich")
    public ReviewValidationResponse validateAndEnrichReview(
            @Valid @RequestBody ReviewValidationRequest payload
    ) {
        return reviewService.validateReview(payload);
    }
}
