package com.aeon.backend.controller;

import com.aeon.backend.service.ReviewValidationService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ReviewController.class)
@Import(ReviewValidationService.class)
class ReviewControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void acceptsValidReviewPayload() throws Exception {
        mockMvc.perform(post("/reviews/validate")
                        .contentType(MediaType.APPLICATION_JSON)
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
                .andExpect(jsonPath("$.source").value("aeon-spring"))
                .andExpect(jsonPath("$.status").value("validated"));
    }

    @Test
    void rejectsInvalidRating() throws Exception {
        mockMvc.perform(post("/reviews/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "userId": "user-123",
                                  "placeName": "Bar Tan Tan",
                                  "address": "Rua informada",
                                  "rating": 6
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.rating", containsString("maximo 5")));
    }

    @Test
    void rejectsMissingRequiredFields() throws Exception {
        mockMvc.perform(post("/reviews/validate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "rating": 4
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.userId").exists())
                .andExpect(jsonPath("$.placeName").exists())
                .andExpect(jsonPath("$.address").exists());
    }
}
