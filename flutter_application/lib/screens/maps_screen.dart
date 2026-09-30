import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../repositories/place_repository.dart';


import '../models/weather.dart';
import '../services/weather_service.dart';

import '../providers/alert_provider.dart';

import '../services/notification_service.dart';

import '../shared/routes/route_names.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {

  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();
  List<Place> filteredPlaces = [];

  @override
  void initState() {

    super.initState();

    filteredPlaces = getAllPlaces();

  }

  void searchPlace(String query) {
    final places = getAllPlaces();

    final results = places.where((place) {
      return place.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredPlaces = results;
    });

    if (results.isNotEmpty) {
      mapController.move(
        LatLng(
          results.first.latitude,
          results.first.longitude,
        ),
        17,
      );
    }
  }

  @override

  Widget build(BuildContext context) {

    final places = filteredPlaces;
    
    // Escutando o AlertProvider reativo conectado ao Firestore
    final alertProvider = Provider.of<AlertProvider>(context);
    final alerts = alertProvider.alerts;

    return Scaffold(

      body: Stack(

        children: [
          // 1. MAPA (Utilizando flutter_map com os marcadores integrados)
          FlutterMap(
            mapController: mapController,
            options: const MapOptions(
              initialCenter: LatLng(-23.5505, -46.6333),
              initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              
              // Camada dos Locais estáticos/filtros
              MarkerLayer(
                markers: places.map((place) {

                  return Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.lightBlueAccent,
                      size: 30,
                    ),
                  );
                }).toList(),
              ),

              // Camada reativa dos Alertas vindos em tempo real do Firestore
              MarkerLayer(
                markers: alerts.map((alert) {
                  Color color = Colors.green;

                  if (alert.nivel == "alto") {
                    color = Colors.red;
                  } else if (alert.nivel == "medio") {
                    color = Colors.orange;
                  }

                  return Marker(
                    point: LatLng(
                      alert.latitude,
                      alert.longitude,
                    ),
                    width: 40, // Aumentado ligeiramente para evitar cortes no ícone
                    height: 40,
                    child: GestureDetector(
                      onTap: () {

                        NotificationService.showLocalAlert(
                          title: '⚠️ Alerta AEON',
                          body: 'Possível risco de alagamento detectado nesta região.',
                        );

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(alert.titulo),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert.descricao),
                                const SizedBox(height: 10),
                                Text(
                                  "Nível: ${alert.nivel}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Fechar"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        Icons.warning,
                        color: color,
                        size: 35,
                      ),
                    ),
                  );
                }).toList(),
              ),

            ],


          ),


          // 2. BARRA DE PESQUISA (Topo)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: searchController,

                onChanged: searchPlace,

                decoration: const InputDecoration(
                  hintText: "Pesquisar...",
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // 3. PAINEL INFERIOR (Draggable/Arrastável)
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.20,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 225, 223, 223),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 93, 90, 90),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    )
                  ],
                ),

                child: ListView(

                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 12),

                    Center(

                      child: Container(
                        width: 40,
                        height: 40 == 4 ? 4 : 4, // Simplificado visualmente mantendo a altura antiga
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cabeçalho com dados da API OpenWeather
                    FutureBuilder<Weather>(
                      future: WeatherService().getWeather(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }

                        final weather = snapshot.data!;

                        return Column(

                          children: [

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  const Text(
                                    "São Paulo",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),

                                  Row(

                                    children: [

                                      Icon(
                                        Icons.cloud_queue,
                                        color: Colors.grey[800],
                                        size: 26,
                                      ),

                                      const SizedBox(width: 6),

                                      Text(
                                        "${weather.temperature.round()}°",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
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

                                  Row(
                                    children: [
                                      const Icon(Icons.water_drop, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Text("Umidade: ${weather.humidity}%"),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      const Icon(Icons.air, color: Colors.teal),
                                      const SizedBox(width: 8),
                                      Text("Vento: ${weather.windSpeed} m/s"),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      const Icon(Icons.cloud, color: Colors.grey),
                                      const SizedBox(width: 8),

                                      Expanded(
                                        child: Text(weather.description),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                          ],
                        );
                      },
                    ),

                    if (places.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            "Nenhum local encontrado",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),


                    buildSection(context, "Hora do Almoço", places),

                    const SizedBox(height: 24),

                    buildSection(context, "Para Explorar", places),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ],

      ),
    );
  }

  static Widget buildSection(BuildContext context, String titulo, List<Place> places) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            padding: const EdgeInsets.only(left: 24, right: 8),
            itemBuilder: (context, index) {
              final place = places[index];

              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteNames.postDetail,
                ),
                child: Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF59E),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: place.image.isNotEmpty
                              ? Image.asset(place.image, fit: BoxFit.cover)
                              : const Center(
                                  child: Icon(Icons.image_outlined, size: 48, color: Colors.black54),
                                ),
                        ),
                      ),

                      Padding(

                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "${place.rating}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.star, color: Colors.amber, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  "• R\$${place.priceRange}",
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Abre às ${place.horario}   •   ${place.distancia}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}