import 'package:flutter/material.dart';

import '../features/weather/domain/weather.dart';
import '../features/weather/data/weather_service.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<Weather>(

      future: WeatherService()
          .getWeather(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {

          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        final weather =
            snapshot.data!;

        return Card(
          child: Padding(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
                  'Clima Atual',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '🌡 ${weather.temperature}°C',
                ),

                Text(
                  '💧 ${weather.humidity}%',
                ),

                Text(
                  '💨 ${weather.windSpeed} m/s',
                ),

                Text(
                  weather.description,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

