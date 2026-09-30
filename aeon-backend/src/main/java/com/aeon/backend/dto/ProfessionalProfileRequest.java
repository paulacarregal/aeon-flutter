package com.aeon.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ProfessionalProfileRequest(

        @NotBlank(message = "ownerUid é obrigatório")
        String ownerUid,

        @NotBlank(message = "Tipo é obrigatório")
        @Size(max = 50)
        String type,

        @NotBlank(message = "Nome é obrigatório")
        @Size(max = 100)
        String displayName,

        @NotBlank(message = "Categoria é obrigatória")
        @Size(max = 100)
        String category,

        @Size(max = 50)
        String document,

        @Size(max = 2000)
        String description,

        @Size(max = 30)
        String phone,

        @Size(max = 200)
        String website,

        @Size(max = 100)
        String instagram,

        @NotBlank(message = "Cidade é obrigatória")
        @Size(max = 100)
        String city,

        @Size(max = 300)
        String address,

        @Size(max = 50)
        String status
) {
}