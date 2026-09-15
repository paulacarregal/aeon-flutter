package com.aeon.backend.service;

import com.aeon.backend.dto.ReviewValidationRequest;
import com.aeon.backend.dto.ReviewValidationResponse;
import org.springframework.stereotype.Service;

//import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class ReviewService {

    private final CatalogService catalogService;

    public ReviewService(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    public ReviewValidationResponse validateReview(
            ReviewValidationRequest payload
    ) {
        Map<String, Object> catalogItem =
                findCatalogItem(
                        payload.placeId(),
                        payload.placeName()
                );

        Set<String> catalogTags =
                new HashSet<>(
                        asStringList(
                                catalogItem == null
                                        ? null
                                        : catalogItem.get("tags")
                        )
                );

        Set<String> userTags = new HashSet<>();

        if (payload.tags() != null) {
            for (String tag : payload.tags()) {
                if (tag != null && !tag.isBlank()) {
                    userTags.add(normalizeTag(tag));
                }
            }
        }

        catalogTags.addAll(userTags);

        List<String> tags = new ArrayList<>(catalogTags);
        tags.sort(Comparator.naturalOrder());

        String placeId =
                payload.placeId() != null
                        && !payload.placeId().isBlank()
                        ? payload.placeId()
                        : catalogItem != null
                                && catalogItem.get("id") != null
                                ? catalogItem.get("id").toString()
                                : slugify(payload.placeName());

        String placeName =
                catalogItem != null
                        && catalogItem.get("name") != null
                        ? catalogItem.get("name").toString()
                        : payload.placeName().trim();

        String address =
                catalogItem != null
                        && catalogItem.get("address") != null
                        ? catalogItem.get("address").toString()
                        : payload.address().trim();

        List<String> profileHints =
                asStringList(
                        catalogItem == null
                                ? null
                                : catalogItem.get("profileHints")
                );

        List<String> reviewPrompts =
                asStringList(
                        catalogItem == null
                                ? null
                                : catalogItem.get("reviewPrompts")
                );

        return new ReviewValidationResponse(
                payload.userId(),
                placeId,
                placeName,
                address,
                payload.rating(),
                payload.comment() == null
                        ? ""
                        : payload.comment().trim(),
                tags,
                payload.spendRange() == null
                        ? null
                        : payload.spendRange().trim(),
                profileHints,
                reviewPrompts,
                "aeon-springboot",
                "validated"
        );
    }

    private Map<String, Object> findCatalogItem(
            String placeId,
            String placeName
    ) {
        return catalogService.findByIdOrName(
                placeId,
                placeName
        );
    }

    private String normalizeTag(String tag) {
        return tag.trim()
                .toLowerCase()
                .replace(" ", "-")
                .replace("Ã¡", "a")
                .replace("Ã ", "a")
                .replace("Ã£", "a")
                .replace("Ã¢", "a")
                .replace("Ã©", "e")
                .replace("Ãª", "e")
                .replace("Ã", "i")
                .replace("Ã³", "o")
                .replace("Ã´", "o")
                .replace("Ãµ", "o")
                .replace("Ãº", "u")
                .replace("Ã§", "c");
    }

    private String slugify(String value) {
        String normalized = normalizeTag(value == null ? "" : value);

        StringBuilder result = new StringBuilder();

        for (int i = 0; i < normalized.length(); i++) {
            char character = normalized.charAt(i);

            if (Character.isLetterOrDigit(character) || character == '-') {
                result.append(character);
            }
        }

        return result.toString();
    }

    private List<String> asStringList(Object value) {
        if (!(value instanceof List<?> list)) {
            return List.of();
        }

        return list.stream()
                .filter(item -> item != null)
                .map(Object::toString)
                .collect(Collectors.toList());
    }
}

