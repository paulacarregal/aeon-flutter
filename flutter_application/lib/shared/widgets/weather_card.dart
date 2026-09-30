import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/weather/presentation/weather_provider.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();

    if (weatherProvider.status == WeatherStatus.loading ||
        weatherProvider.status == WeatherStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (weatherProvider.weather == null) return const SizedBox.shrink();

    final weather = weatherProvider.weather!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clima Atual',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text('🌡 ${weather.temperature}°C'),
            Text('💧 ${weather.humidity}%'),
            Text('💨 ${weather.windSpeed} m/s'),
            Text(weather.description),
          ],
        ),
      ),
    );
  }
}
