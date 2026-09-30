package com.aeon.backend.service;

import com.aeon.backend.dto.HealthResponse;
import org.springframework.stereotype.Service;

@Service
public class HealthService {

    public HealthResponse getHealth() {
        return new HealthResponse(
                "UP",
                "AEON Backend",
                "1.0.0"
        );
    }
}
