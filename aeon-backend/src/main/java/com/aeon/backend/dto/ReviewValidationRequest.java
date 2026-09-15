package com.aeon.backend.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

import java.util.List;

public record ReviewValidationRequest(

        @NotBlank(message = "userId e obrigatorio")
        String userId,

        String placeId,

        @NotBlank(message = "placeName e obrigatorio")
        String placeName,

        @NotBlank(message = "address e obrigatorio")
        String address,

        @Min(value = 1, message = "rating deve ser no minimo 1")
        @Max(value = 5, message = "rating deve ser no maximo 5")
        int rating,

        String comment,

        List<String> tags,

        String spendRange
) {
}
