package com.aeon.backend.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record ReviewValidationRequest(
        @NotBlank
        String userId,

        String placeId,

        @NotBlank
        String placeName,

        @NotBlank
        String address,

        @NotNull
        @Min(1)
        @Max(5)
        Integer rating,

        String comment,

        List<String> tags,

        String spendRange
) {
}
