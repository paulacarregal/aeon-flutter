class Weather {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String description;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('temperature')) {
      return Weather(
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
        humidity: (json['humidity'] as num?)?.toInt() ?? 0,
        windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0,
        description: json['description'] as String? ?? '',
      );
    }

    return Weather(
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
    );
  }
}
