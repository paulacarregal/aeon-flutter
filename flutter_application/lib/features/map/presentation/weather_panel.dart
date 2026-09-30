import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../weather/presentation/weather_provider.dart';

class WeatherPanel extends StatefulWidget {
  const WeatherPanel({super.key});

  @override
  State<WeatherPanel> createState() => _WeatherPanelState();
}

class _WeatherPanelState extends State<WeatherPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<WeatherProvider>();
      if (provider.status == WeatherStatus.initial) {
        provider.fetch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();

    if (wp.status == WeatherStatus.loading ||
        wp.status == WeatherStatus.initial) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (wp.weather == null) return const SizedBox.shrink();

    final weather = wp.weather!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'São Paulo',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Row(
                children: [
                  Icon(Icons.cloud_queue, color: Colors.grey[800], size: 26),
                  const SizedBox(width: 6),
                  Text(
                    '${weather.temperature.round()}°',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(children: [
                const Icon(Icons.water_drop, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Umidade: ${weather.humidity}%'),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.air, color: Colors.teal),
                const SizedBox(width: 8),
                Text('Vento: ${weather.windSpeed} m/s'),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.cloud, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(weather.description)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
