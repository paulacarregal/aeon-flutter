package com.aeon.backend.dto;

import java.util.List;

public record PlaceCandidate(
        String id,
        String name,
        double rating,
        List<String> tags,
        boolean indoor,
        Double distanceMeters
) {
}
