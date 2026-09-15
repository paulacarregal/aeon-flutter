package com.aeon.backend.service;

import com.aeon.backend.dto.DeviceContext;
import com.aeon.backend.dto.NotificationContextRequest;
import com.aeon.backend.dto.NotificationContextResponse;
import com.aeon.backend.dto.NotificationResponse;
import com.aeon.backend.dto.PlaceCandidate;
import com.aeon.backend.dto.RecommendationContext;
import com.aeon.backend.dto.RecommendationProfile;
import com.aeon.backend.dto.RecommendationResponse;
import com.aeon.backend.dto.RecommendPlacesRequest;
import org.springframework.stereotype.Service;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class RecommendationService {

    private final CatalogService catalogService;

    public RecommendationService(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    public RecommendationResponse recommendPlaces(
            RecommendPlacesRequest payload
    ) {

        RecommendationProfile profile =
                safeProfile(payload.profile());

        RecommendationContext context =
                safeContext(payload.context());

        List<PlaceCandidate> places =
                payload.places() != null
                        ? payload.places()
                        : List.of();

        List<ScoredPlace> scored =
                places.stream()
                        .map(place ->
                                new ScoredPlace(
                                        place,
                                        scorePlace(
                                                place,
                                                profile,
                                                context
                                        )
                                )
                        )
                        .sorted(
                                Comparator.comparingInt(
                                        ScoredPlace::score
                                ).reversed()
                        )
                        .limit(5)
                        .toList();

        List<com.aeon.backend.dto.RecommendationItem> ranked =
                scored.stream()
                        .map(item ->
                                new com.aeon.backend.dto.RecommendationItem(
                                        item.place().id(),
                                        item.place().name(),
                                        item.place().rating(),
                                        item.place().tags(),
                                        item.place().indoor(),
                                        item.place().distanceMeters(),
                                        item.score()
                                )
                        )
                        .toList();

        String message =
                recommendationMessage(
                        scored.isEmpty()
                                ? null
                                : scored.get(0).place(),
                        context
                );

        return new RecommendationResponse(
                ranked,
                message
        );
    }
    public NotificationContextResponse notificationContext(
            NotificationContextRequest payload
    ) {

        RecommendationProfile profile =
                safeProfile(payload.profile());

        DeviceContext device =
                safeDevice(payload.device());

        RecommendationContext context =
                contextFromDevice(device);

        List<Map<String, Object>> catalog =
                catalogService.findAll();

        List<ScoredCatalogItem> ranked =
                new ArrayList<>();

        for (Map<String, Object> item : catalog) {

            Map<String, Object> candidate =
                    new java.util.HashMap<>(item);

            Double distance =
                    distanceMeters(
                            device.latitude(),
                            device.longitude(),
                            asDouble(item.get("latitude")),
                            asDouble(item.get("longitude"))
                    );

            candidate.put(
                    "distanceMeters",
                    distance
            );

            int score =
                    scoreCatalogItem(
                            candidate,
                            profile,
                            context
                    );

            candidate.put("score", score);

            ranked.add(
                    new ScoredCatalogItem(
                            candidate,
                            score
                    )
            );
        }

        ranked.sort(
                Comparator.comparingInt(
                        ScoredCatalogItem::score
                ).reversed()
        );

        Map<String, Object> selected =
                ranked.isEmpty()
                        ? null
                        : ranked.get(0).item();

        List<Map<String, Object>> alternatives =
                ranked.stream()
                        .skip(1)
                        .limit(3)
                        .map(ScoredCatalogItem::item)
                        .toList();

        NotificationResponse notification =
                buildNotification(
                        selected,
                        context
                );

        return new NotificationContextResponse(
                notification,
                selected,
                alternatives,
                context
        );
    }

    private int scorePlace(
            PlaceCandidate place,
            RecommendationProfile profile,
            RecommendationContext context
    ) {

        Set<String> placeTags =
                new HashSet<>(
                        safeList(place.tags())
                );

        Set<String> preferredTags =
                new HashSet<>(
                        safeList(profile.preferredTags())
                );

        double score =
                place.rating() * 2;

        long matchingTags =
                placeTags.stream()
                        .filter(preferredTags::contains)
                        .count();

        score += matchingTags * 12;

        if (context.raining() && place.indoor()) {
            score += 8;
        }

        if (context.night()
                && placeTags.contains("night")) {
            score += 6;
        }

        if (!context.night()
                && placeTags.contains("day")) {
            score += 6;
        }

        if (context.maxDistanceMeters() != null
                && place.distanceMeters() != null) {

            score += Math.max(
                    0,
                    8 - place.distanceMeters() / 500
            );
        }

        return (int) Math.round(score);
    }

    private String recommendationMessage(
            PlaceCandidate place,
            RecommendationContext context
    ) {

        if (place == null) {
            return "Tem uma experiencia esperando por voce.";
        }

        if (context.raining()) {
            return place.name()
                    + " combina com agora e fica protegido do clima.";
        }

        return place.name()
                + " combina com seu perfil hoje.";
    }

    private RecommendationContext contextFromDevice(
            DeviceContext device
    ) {

        String description =
                device.weatherDescription() != null
                        ? device.weatherDescription().toLowerCase()
                        : "";

        boolean raining =
                description.contains("chuva")
                        || description.contains("rain")
                        || description.contains("garoa");

        boolean night =
                isNightNow();

        return new RecommendationContext(
                raining,
                night,
                3500.0,
                device.transportMode()
        );
    }

    private int scoreCatalogItem(
            Map<String, Object> item,
            RecommendationProfile profile,
            RecommendationContext context
    ) {

        PlaceCandidate place =
                new PlaceCandidate(
                        asString(item.get("id")),
                        asString(item.get("name")),
                        asDoubleOrZero(item.get("rating")),
                        asStringList(item.get("tags")),
                        asBoolean(item.get("indoor")),
                        asDouble(item.get("distanceMeters"))
                );

        double score =
                scorePlaceAsDouble(
                        place,
                        profile,
                        context
                );

        if ("event".equals(item.get("kind"))) {
            score += 5;
        }

        if (context.raining()
                && !asBoolean(item.get("indoor"))) {
            score -= 12;
        }

        Double distance =
                asDouble(item.get("distanceMeters"));

        if (distance != null) {
            score += Math.max(
                    0,
                    10 - distance / 600
            );
        }

        return (int) Math.round(score);
    }

    private double scorePlaceAsDouble(
            PlaceCandidate place,
            RecommendationProfile profile,
            RecommendationContext context
    ) {

        Set<String> placeTags =
                new HashSet<>(
                        safeList(place.tags())
                );

        Set<String> preferredTags =
                new HashSet<>(
                        safeList(profile.preferredTags())
                );

        double score =
                place.rating() * 2;

        long matchingTags =
                placeTags.stream()
                        .filter(preferredTags::contains)
                        .count();

        score += matchingTags * 12;

        if (context.raining() && place.indoor()) {
            score += 8;
        }

        if (context.night()
                && placeTags.contains("night")) {
            score += 6;
        }

        if (!context.night()
                && placeTags.contains("day")) {
            score += 6;
        }

        if (context.maxDistanceMeters() != null
                && place.distanceMeters() != null) {

            score += Math.max(
                    0,
                    8 - place.distanceMeters() / 500
            );
        }

        return score;
    }

    private NotificationResponse buildNotification(
            Map<String, Object> item,
            RecommendationContext context
    ) {

        if (item == null) {
            return new NotificationResponse(
                    "AEON",
                    "Tem uma experiencia em SP que combina com voce.",
                    "recommendation",
                    null,
                    null,
                    null
            );
        }

        String template =
                asString(item.get("notificationTemplate"));

        if (template == null || template.isBlank()) {
            template =
                    "{name} combina com seu perfil.";
        }

        String body =
                formatTemplate(
                        template,
                        item
                );

        if (context.raining()
                && asBoolean(item.get("indoor"))) {
            body +=
                    " E ainda fica protegido do clima.";
        }

        return new NotificationResponse(
                "AEON recomenda",
                body,
                "recommendation",
                asString(item.get("id")),
                asDouble(item.get("latitude")),
                asDouble(item.get("longitude"))
        );
    }

    private String formatTemplate(
            String template,
            Map<String, Object> item
    ) {

        String result = template;

        for (Map.Entry<String, Object> entry :
                item.entrySet()) {

            String placeholder =
                    "{" + entry.getKey() + "}";

            String value =
                    entry.getValue() != null
                            ? entry.getValue().toString()
                            : "";

            result =
                    result.replace(
                            placeholder,
                            value
                    );
        }

        return result;
    }

    private boolean isNightNow() {

        int hour =
                LocalTime.now().getHour();

        return hour >= 18 || hour < 6;
    }

    private Double distanceMeters(
            Double lat1,
            Double lon1,
            Double lat2,
            Double lon2
    ) {

        if (lat1 == null
                || lon1 == null
                || lat2 == null
                || lon2 == null) {
            return null;
        }

        double radius = 6371000;

        double phi1 =
                Math.toRadians(lat1);

        double phi2 =
                Math.toRadians(lat2);

        double deltaPhi =
                Math.toRadians(lat2 - lat1);

        double deltaLambda =
                Math.toRadians(lon2 - lon1);

        double a =
                Math.pow(
                        Math.sin(deltaPhi / 2),
                        2
                )
                + Math.cos(phi1)
                * Math.cos(phi2)
                * Math.pow(
                        Math.sin(deltaLambda / 2),
                        2
                );

        return radius
                * 2
                * Math.atan2(
                        Math.sqrt(a),
                        Math.sqrt(1 - a)
                );
    }

    private RecommendationProfile safeProfile(
            RecommendationProfile profile
    ) {

        if (profile == null) {
            return new RecommendationProfile(
                    null,
                    List.of()
            );
        }

        return new RecommendationProfile(
                profile.name(),
                safeList(profile.preferredTags())
        );
    }

    private RecommendationContext safeContext(
            RecommendationContext context
    ) {

        if (context == null) {
            return new RecommendationContext(
                    false,
                    false,
                    null,
                    null
            );
        }

        return context;
    }

    private DeviceContext safeDevice(
            DeviceContext device
    ) {

        if (device == null) {
            return new DeviceContext(
                    null,
                    null,
                    null,
                    null,
                    null
            );
        }

        return device;
    }

    private List<String> safeList(
            List<String> values
    ) {

        return values != null
                ? values
                : List.of();
    }

    private String asString(Object value) {

        return value != null
                ? value.toString()
                : null;
    }

    private double asDoubleOrZero(Object value) {

        Double result =
                asDouble(value);

        return result != null
                ? result
                : 0;
    }

    private Double asDouble(Object value) {

        if (value == null) {
            return null;
        }

        if (value instanceof Number number) {
            return number.doubleValue();
        }

        try {
            return Double.parseDouble(
                    value.toString()
            );
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean asBoolean(Object value) {

        if (value instanceof Boolean bool) {
            return bool;
        }

        return Boolean.parseBoolean(
                asString(value)
        );
    }

    private List<String> asStringList(
            Object value
    ) {

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

    private record ScoredPlace(
            PlaceCandidate place,
            int score
    ) {
    }

    private record ScoredCatalogItem(
            Map<String, Object> item,
            int score
    ) {
    }
}


