import '../../profile/domain/recommendation_profile.dart';
import '../domain/place.dart';

class PlaceRecommendationService {
  List<Place> rankPlaces({
    required List<Place> places,
    required RecommendationProfile profile,
  }) {
    final ranked = [...places];
    ranked.sort((a, b) {
      final scoreB = scorePlace(b, profile);
      final scoreA = scorePlace(a, profile);
      final scoreComparison = scoreB.compareTo(scoreA);
      if (scoreComparison != 0) return scoreComparison;
      return b.rating.compareTo(a.rating);
    });
    return ranked;
  }

  int scorePlace(Place place, RecommendationProfile profile) {
    var score = 0;

    score += place.tags.intersection(profile.preferredTags).length * 12;
    score += (place.rating * 2).round();

    if (profile.prefersPremium && place.priceLevel >= 3) score += 8;
    if (!profile.prefersPremium && place.priceLevel <= 2) score += 5;
    if (profile.prefersOutdoor && !place.indoor) score += 10;
    if (!profile.prefersOutdoor && place.indoor) score += 6;
    if (profile.prefersDaytime && place.daytime) score += 8;
    if (!profile.prefersDaytime && place.nightlife) score += 8;
    if (profile.prefersActive && place.tags.contains('active')) score += 8;
    if (!profile.prefersActive && place.tags.contains('calm')) score += 8;
    if (profile.prefersSocial && place.tags.contains('social')) score += 6;
    if (profile.prefersNovelty && place.tags.contains('new')) score += 6;
    if (profile.spontaneous && place.tags.contains('nearby')) score += 4;

    return score;
  }
}
