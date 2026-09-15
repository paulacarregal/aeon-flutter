package com.aeon.backend.controller;

import com.aeon.backend.service.CatalogService;
import com.aeon.backend.service.ReviewService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class ReviewControllerTest {

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        ObjectMapper objectMapper = new ObjectMapper();
        CatalogService catalogService = new CatalogService(objectMapper);
        ReviewService reviewService = new ReviewService(catalogService);
        ReviewController reviewController = new ReviewController(reviewService);

        mockMvc = MockMvcBuilders
                .standaloneSetup(reviewController)
                .build();
    }

    @Test
    void acceptsValidReviewPayload() throws Exception {
        mockMvc.perform(post("/reviews/validate")
                        .contentType("application/json")
                        .content("""
                                {
                                  "userId": "user-123",
                                  "placeId": "bar-tan-tan",
                                  "placeName": "Bar Tan Tan",
                                  "address": "Rua informada",
                                  "rating": 5,
                                  "comment": "Gostei",
                                  "tags": ["Ambiente"],
                                  "spendRange": "50+"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value("user-123"))
                .andExpect(jsonPath("$.placeId").value("bar-tan-tan"))
                .andExpect(jsonPath("$.placeName").value("Bar Tan Tan"))
                .andExpect(jsonPath("$.rating").value(5))
                .andExpect(jsonPath("$.tags", hasItem("ambiente")))
                .andExpect(jsonPath("$.profileHints", hasItem("Pioneiro Urbano")))
                .andExpect(jsonPath("$.reviewPrompts", hasItem("drinks")))
                .andExpect(jsonPath("$.source").value("aeon-springboot"))
                .andExpect(jsonPath("$.status").value("validated"));
    }

    @Test
    void rejectsInvalidRating() throws Exception {
        mockMvc.perform(post("/reviews/validate")
                        .contentType("application/json")
                        .content("""
                                {
                                  "userId": "user-123",
                                  "placeName": "Bar Tan Tan",
                                  "address": "Rua informada",
                                  "rating": 6
                                }
                                """))
                .andExpect(status().isBadRequest());
    }

    @Test
    void rejectsMissingRequiredFields() throws Exception {
        mockMvc.perform(post("/reviews/validate")
                        .contentType("application/json")
                        .content("""
                                {
                                  "rating": 4
                                }
                                """))
                .andExpect(status().isBadRequest());
    }
}