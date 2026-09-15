package com.aeon.backend.dto;

import java.util.List;
import java.util.Map;

public record CatalogResponse(
        List<Map<String, Object>> items,
        int count
) {
}
