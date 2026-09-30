import 'package:firebase_ai/firebase_ai.dart';

import '../../map/domain/place.dart';
import '../../profile/domain/recommendation_profile.dart';
import '../../weather/domain/weather.dart';

class AiRecommendationResult {
  final String title;
  final String body;
  final Place place;

  const AiRecommendationResult({
    required this.title,
    required this.body,
    required this.place,
  });
}

class AiRecommendationService {
  AiRecommendationService({GenerativeModel? model})
      : _model = model ??
            FirebaseAI.googleAI().generativeModel(
              model: 'gemini-3.6-flash',
            );

  final GenerativeModel _model;

  Future<AiRecommendationResult> generateNotification({
    required RecommendationProfile? profile,
    required Weather? weather,
    required List<Place> places,
    String transportMode = 'a pe',
    Map<String, double> preferenceWeights = const {},
  }) async {
    final candidates = places.take(5).toList();
    if (candidates.isEmpty) {
      throw StateError('Nao ha locais para recomendar.');
    }

    try {
      final response = await _model.generateContent([
        Content.text(
          _buildPrompt(
            profile: profile,
            weather: weather,
            places: candidates,
            transportMode: transportMode,
            preferenceWeights: preferenceWeights,
          ),
        ),
      ]);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        return _fallback(profile: profile, weather: weather, place: candidates.first);
      }
      return AiRecommendationResult(
        title: 'AEON recomenda',
        body: _cleanNotification(text),
        place: candidates.first,
      );
    } catch (_) {
      return _fallback(profile: profile, weather: weather, place: candidates.first);
    }
  }

  String _buildPrompt({
    required RecommendationProfile? profile,
    required Weather? weather,
    required List<Place> places,
    required String transportMode,
    required Map<String, double> preferenceWeights,
  }) {
    final profileName = profile?.name ?? 'perfil ainda novo';
    final tags = profile?.preferredTags.join(', ');
    final weatherText = weather == null
        ? 'clima indisponivel'
        : '${weather.description}, ${weather.temperature.toStringAsFixed(0)} graus';
    final placesText = places
        .map(
          (place) =>
              '- ${place.name}: preco ${place.priceRange}, nota ${place.rating}, tags ${place.tags.join(', ')}',
        )
        .join('\n');
    final preferenceText = preferenceWeights.isEmpty
        ? 'sem ajustes manuais'
        : preferenceWeights.entries
            .map((entry) => '${entry.key}: ${entry.value.toStringAsFixed(1)}')
            .join(', ');

    return '''
Voce e o motor de recomendacao do app AEON em Sao Paulo.
Crie UMA notificacao curta em portugues do Brasil para convidar o usuario a visitar um lugar.

Regras:
- Maximo 110 caracteres.
- Nao use emoji.
- Nao invente lugares fora da lista.
- Use tom natural, urbano e direto.
- Cite o nome do lugar recomendado.
- Nao explique o raciocinio.
- Responda apenas com o texto da notificacao.

Perfil do usuario: $profileName
Tags preferidas: ${tags == null || tags.isEmpty ? 'sem tags ainda' : tags}
Clima agora: $weatherText
Modal de transporte: $transportMode
Preferencias ajustadas em escala 0.0 a 1.0, onde 0.5 e neutro: $preferenceText
Lugares candidatos:
$placesText
''';
  }

  AiRecommendationResult _fallback({
    required RecommendationProfile? profile,
    required Weather? weather,
    required Place place,
  }) {
    final weatherText = weather?.description.toLowerCase() ?? '';
    final rainy = weatherText.contains('chuva') || weatherText.contains('garoa');
    final body = rainy && place.indoor
        ? '${place.name} combina com seu perfil e fica protegido do clima.'
        : '${place.name} combina com seu perfil agora.';

    return AiRecommendationResult(
      title: 'AEON recomenda',
      body: body,
      place: place,
    );
  }

  String _cleanNotification(String text) {
    final oneLine = text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');
    return oneLine.length <= 120 ? oneLine : '${oneLine.substring(0, 117)}...';
  }
}
