class RecommendationProfile {
  final String name;
  final Set<String> preferredTags;
  final bool prefersPremium;
  final bool prefersNovelty;
  final bool prefersActive;
  final bool prefersDaytime;
  final bool prefersSocial;
  final bool prefersOutdoor;
  final bool spontaneous;

  const RecommendationProfile({
    required this.name,
    required this.preferredTags,
    required this.prefersPremium,
    required this.prefersNovelty,
    required this.prefersActive,
    required this.prefersDaytime,
    required this.prefersSocial,
    required this.prefersOutdoor,
    required this.spontaneous,
  });
}
