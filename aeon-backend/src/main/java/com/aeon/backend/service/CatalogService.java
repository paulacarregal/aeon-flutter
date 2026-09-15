package com.aeon.backend.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class CatalogService {

    private static final String CATALOG_PATH = "data/sp_catalog.json";

    private final ObjectMapper objectMapper;

    public CatalogService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public List<Map<String, Object>> findAll() {

        try {
            ClassPathResource resource =
                    new ClassPathResource(CATALOG_PATH);

            try (InputStream inputStream =
                         resource.getInputStream()) {

                return objectMapper.readValue(
                        inputStream,
                        new TypeReference<List<Map<String, Object>>>() {}
                );
            }

        } catch (Exception e) {
            throw new RuntimeException(
                    "Erro ao carregar catálogo AEON.",
                    e
            );
        }
    }

    public Map<String, Object> findById(String placeId) {

        return findAll()
                .stream()
                .filter(item ->
                        placeId.equals(item.get("id"))
                )
                .findFirst()
                .orElse(null);
    }

    public Map<String, Object> findByName(String placeName) {

        if (placeName == null || placeName.isBlank()) {
            return null;
        }

        String normalizedName =
                normalize(placeName);

        return findAll()
                .stream()
                .filter(item -> {

                    Object name =
                            item.get("name");

                    return name != null
                            && normalize(name.toString())
                            .equals(normalizedName);
                })
                .findFirst()
                .orElse(null);
    }

    public Map<String, Object> findByIdOrName(
            String placeId,
            String placeName
    ) {

        if (placeId != null && !placeId.isBlank()) {

            Map<String, Object> item =
                    findById(placeId);

            if (item != null) {
                return item;
            }
        }

        return findByName(placeName);
    }

    public List<String> getReviewPrompts(String placeId) {

        Map<String, Object> item =
                findById(placeId);

        if (item == null) {
            return List.of();
        }

        return toStringList(
                item.get("reviewPrompts")
        );
    }

    public List<String> getProfileHints(String placeId) {

        Map<String, Object> item =
                findById(placeId);

        if (item == null) {
            return List.of();
        }

        return toStringList(
                item.get("profileHints")
        );
    }

    private List<String> toStringList(Object value) {

        if (!(value instanceof List<?> list)) {
            return List.of();
        }

        List<String> result =
                new ArrayList<>();

        for (Object item : list) {

            if (item != null) {
                result.add(item.toString());
            }
        }

        return result;
    }

    private String normalize(String value) {

        return value
                .trim()
                .toLowerCase()
                .replace(" ", "-")
                .replace("á", "a")
                .replace("à", "a")
                .replace("ã", "a")
                .replace("â", "a")
                .replace("é", "e")
                .replace("ê", "e")
                .replace("í", "i")
                .replace("ó", "o")
                .replace("ô", "o")
                .replace("õ", "o")
                .replace("ú", "u")
                .replace("ç", "c");
    }
}
