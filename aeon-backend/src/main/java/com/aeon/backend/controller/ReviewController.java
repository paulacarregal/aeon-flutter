package com.aeon.backend.controller;

import com.aeon.backend.dto.ReviewValidationRequest;
import com.aeon.backend.dto.ReviewValidationResponse;
import com.aeon.backend.service.ReviewValidationService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ReviewController {

    private final ReviewValidationService service;

    public ReviewController(ReviewValidationService service) {
        this.service = service;
    }

    @PostMapping("/reviews/validate")
    public ReviewValidationResponse validate(
            @Valid @RequestBody ReviewValidationRequest request
    ) {
        return service.validate(request);
    }
}
