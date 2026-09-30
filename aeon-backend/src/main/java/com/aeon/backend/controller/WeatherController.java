package com.aeon.backend.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@RestController
public class WeatherController {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    @PostMapping("/weather")
    public ResponseEntity<?> getWeather(
            @RequestBody Map<String, String> request) throws Exception {

        String city = request.get("city");

        if (city == null || city.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "city is required"));
        }

        String apiKey = System.getenv("OPENWEATHER_KEY");

        if (apiKey == null || apiKey.isBlank()) {
            return ResponseEntity.internalServerError()
                    .body(Map.of(
                            "error",
                            "OPENWEATHER_KEY nao configurada no backend."
                    ));
        }

        String encodedCity =
                URLEncoder.encode(city, StandardCharsets.UTF_8);

        String url =
                "https://api.openweathermap.org/data/2.5/weather"
                        + "?q=" + encodedCity
                        + "&units=metric"
                        + "&lang=pt_br"
                        + "&appid=" + apiKey;

        HttpRequest httpRequest = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .GET()
                .header("Accept", "application/json")
                .build();

        HttpResponse<String> response =
                httpClient.send(
                        httpRequest,
                        HttpResponse.BodyHandlers.ofString()
                );

        JsonNode data = objectMapper.readTree(response.body());

        if (response.statusCode() >= 400) {
            return ResponseEntity.status(response.statusCode())
                    .body(Map.of(
                            "error",
                            "OpenWeather request failed",
                            "status",
                            response.statusCode()
                    ));
        }

        double temperature =
                data.path("main").path("temp").asDouble();

        int humidity =
                data.path("main").path("humidity").asInt();

        double windSpeed =
                data.path("wind").path("speed").asDouble();

        String description =
                data.path("weather")
                        .path(0)
                        .path("description")
                        .asText();

        return ResponseEntity.ok(Map.of(
                "temperature", temperature,
                "humidity", humidity,
                "windSpeed", windSpeed,
                "description", description
        ));
    }
}