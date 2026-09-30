package com.aeon.backend.service;

import com.aeon.backend.dto.ReviewValidationRequest;
import com.aeon.backend.dto.ReviewValidationResponse;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

@Service
public class ReviewValidationService {

    private static final List<CatalogReviewMetadata> REVIEW_METADATA =
            List.of(
                    new CatalogReviewMetadata(
                            "bar-tan-tan",
                            "Bar Tan Tan",
                            "Rua Fradique Coutinho, 153 - Pinheiros",
                            List.of(
                                    "night",
                                    "social",
                                    "premium",
                                    "urban",
                                    "experience",
                                    "indoor"
                            ),
                            List.of(
                                    "Pioneiro Urbano",
                                    "Explorador Social"
                            ),
                            List.of(
                                    "drinks",
                                    "ambiente",
                                    "musica",
                                    "fila",
                                    "preco"
                            )
                    )
            );

    public ReviewValidationResponse validate(
            ReviewValidationRequest request
    ) {
        CatalogReviewMetadata catalogItem =
                findCatalogItem(request.placeId(), request.placeName());

        Set<String> tags = new LinkedHashSet<>();

        if (catalogItem != null) {
            tags.addAll(catalogItem.tags());
        }

        if (request.tags() != null) {
            request.tags().stream()
                    .filter(tag -> tag != null && !tag.isBlank())
                    .map(this::normalizeTag)
                    .forEach(tags::add);
        }

        List<String> sortedTags = new ArrayList<>(tags);
        sortedTags.sort(Comparator.naturalOrder());

        String placeId = firstNonBlank(
                request.placeId(),
                catalogItem != null ? catalogItem.id() : null,
                slugify(request.placeName())
        );

        return new ReviewValidationResponse(
                request.userId().trim(),
                placeId,
                catalogItem != null
                        ? catalogItem.name()
                        : request.placeName().trim(),
                catalogItem != null
                        ? catalogItem.address()
                        : request.address().trim(),
                request.rating(),
                trimToEmpty(request.comment()),
                sortedTags,
                trimToNull(request.spendRange()),
                catalogItem != null
                        ? catalogItem.profileHints()
                        : List.of(),
                catalogItem != null
                        ? catalogItem.reviewPrompts()
                        : List.of(),
                "aeon-spring",
                "validated"
        );
    }

    private CatalogReviewMetadata findCatalogItem(
            String placeId,
            String placeName
    ) {
        String normalizedName = slugify(placeName);

        return REVIEW_METADATA.stream()
                .filter(item ->
                        isSameNonBlank(item.id(), placeId)
                                || item.slug().equals(normalizedName)
                )
                .findFirst()
                .orElse(null);
    }

    private boolean isSameNonBlank(String expected, String actual) {
        return actual != null
                && !actual.isBlank()
                && expected.equals(actual.trim());
    }

    private String normalizeTag(String value) {
        String normalized = Normalizer
                .normalize(value.trim(), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");

        return normalized
                .toLowerCase(Locale.ROOT)
                .replace(" ", "-");
    }

    private String slugify(String value) {
        return normalizeTag(value)
                .replaceAll("[^a-z0-9-]", "");
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String trimToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim();
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value.trim();
            }
        }

        return "";
    }

    private record CatalogReviewMetadata(
            String id,
            String name,
            String address,
            List<String> tags,
            List<String> profileHints,
            List<String> reviewPrompts
    ) {

        String slug() {
            String normalized = Normalizer
                    .normalize(name.trim(), Normalizer.Form.NFD)
                    .replaceAll("\\p{M}", "");

            return normalized
                    .toLowerCase(Locale.ROOT)
                    .replace(" ", "-")
                    .replaceAll("[^a-z0-9-]", "");
        }
    }
}
