package com.aeon.backend.dto;

public record ProfessionalProfileResponse(

        String id,

        String ownerUid,

        String type,

        String displayName,

        String category,

        String document,

        String description,

        String phone,

        String website,

        String instagram,

        String city,

        String address,

        String status,

        boolean active
) {
}