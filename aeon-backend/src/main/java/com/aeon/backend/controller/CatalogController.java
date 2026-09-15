package com.aeon.backend.controller;

import com.aeon.backend.dto.CatalogResponse;
import com.aeon.backend.dto.ReviewPromptsResponse;
import com.aeon.backend.service.CatalogService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/catalog")
public class CatalogController {

    private final CatalogService catalogService;

    public CatalogController(
            CatalogService catalogService
    ) {
        this.catalogService = catalogService;
    }

    @GetMapping
    public CatalogResponse getCatalog() {
        List<Map<String, Object>> items = catalogService.findAll();

        return new CatalogResponse(
                items,
                items.size()
        );
    }

    @GetMapping("/{placeId}/review-prompts")
    public ReviewPromptsResponse getReviewPrompts(
            @PathVariable String placeId
    ) {
        Map<String, Object> item = catalogService.findById(placeId);

        if (item == null) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "Local nao encontrado."
            );
        }

        return new ReviewPromptsResponse(
                asString(item.get("id")),
                asString(item.get("name")),
                catalogService.getProfileHints(placeId),
                catalogService.getReviewPrompts(placeId),
                asStringList(item.get("tags"))
        );
    }

    private String asString(Object value) {
        return value == null ? null : value.toString();
    }

    private List<String> asStringList(Object value) {
        if (!(value instanceof List<?> list)) {
            return List.of();
        }

        return list.stream()
                .filter(item -> item != null)
                .map(Object::toString)
                .toList();
    }
}
