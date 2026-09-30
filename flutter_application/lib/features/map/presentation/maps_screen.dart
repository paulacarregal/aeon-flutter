import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import './alert_marker_widget.dart';
import './map_search_bar.dart';
import './place_card.dart';
import './place_provider.dart';
import '../domain/place.dart';
import '../../alerts/presentation/alert_provider.dart';
import '../../recommendations/presentation/ai_recommendation_provider.dart';
import '../../weather/presentation/weather_provider.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/theme/colors.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  final _locationService = LocationService();

  String? _aiCardBody;
  LatLng? _currentPosition;
  Place? _routeDestination;
  bool _locationLoading = true;
  double _maxDistanceKm = 8;
  Map<String, double> _preferenceWeights = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetch();
      _loadRecommendationPreferences();
      _loadCurrentPosition();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentPosition() async {
    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (position == null) {
      setState(() => _locationLoading = false);
      return;
    }

    final latLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = latLng;
      _locationLoading = false;
    });
    _mapController.move(latLng, 17);
  }

  Future<void> _loadRecommendationPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .get();
      final prefs = doc.data()?['recommendationPreferences'] as Map?;
      final data = doc.data() ?? {};
      final maxDistance =
          (prefs?['maxDistanceKm'] as num?)?.toDouble() ??
          (data['maxDistanceKm'] as num?)?.toDouble();
      if (!mounted) return;
      setState(() {
        if (maxDistance != null) _maxDistanceKm = maxDistance;
        _preferenceWeights = {
          'outdoor': (prefs?['outdoor'] as num?)?.toDouble() ??
              (data['radarOutdoor'] as num?)?.toDouble() ??
              0.5,
          'active': (prefs?['active'] as num?)?.toDouble() ??
              (data['radarActive'] as num?)?.toDouble() ??
              0.5,
          'night': (prefs?['night'] as num?)?.toDouble() ??
              (data['radarNight'] as num?)?.toDouble() ??
              0.5,
          'social': (prefs?['social'] as num?)?.toDouble() ??
              (data['radarSocial'] as num?)?.toDouble() ??
              0.5,
          'novelty': (prefs?['novelty'] as num?)?.toDouble() ??
              (data['radarNovelty'] as num?)?.toDouble() ??
              0.5,
        };
      });
    } catch (_) {
      
    }
  }

  Future<void> _sendAiRecommendation(BuildContext context) async {
    final places = _rankByUserRadar(
      _placesInsidePreferenceRadius(context.read<PlaceProvider>().filtered),
    );
    final profile = context.read<PlaceProvider>().profile;
    final weather = context.read<WeatherProvider>().weather;
    final ai = context.read<AiRecommendationProvider>();

    final result = await ai.generateNotification(
      profile: profile,
      weather: weather,
      places: places,
      preferenceWeights: _preferenceWeights,
    );

    if (!context.mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel gerar recomendacao.')),
      );
      return;
    }

    if (!context.mounted) return;
    setState(() {
      _aiCardBody = result.body;
      _routeDestination = result.place;
    });
    if (_currentPosition != null) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints([
            _currentPosition!,
            LatLng(result.place.latitude, result.place.longitude),
          ]),
          padding: const EdgeInsets.fromLTRB(54, 130, 54, 260),
        ),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.body)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final placeProvider = context.watch<PlaceProvider>();
    final alertProvider = context.watch<AlertProvider>();
    final places = placeProvider.filtered;
    final alerts = alertProvider.alerts;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(-23.5505, -46.6333),
              initialZoom: 12.7,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'br.com.aeon.app',
              ),
              if (_currentPosition != null && _routeDestination != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        _currentPosition!,
                        LatLng(
                          _routeDestination!.latitude,
                          _routeDestination!.longitude,
                        ),
                      ],
                      color: AppColors.purpleAeon,
                      strokeWidth: 5,
                      borderColor: AppColors.yellowAeon,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: places.map((place) {
                  return Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.purpleAeon,
                      size: 32,
                    ),
                  );
                }).toList(),
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 42,
                      height: 42,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: AppColors.purpleAeon,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: alerts.map((alert) {
                  return Marker(
                    point: LatLng(alert.latitude, alert.longitude),
                    width: 40,
                    height: 40,
                    child: AlertMarkerWidget(alert: alert),
                  );
                }).toList(),
              ),
            ],
          ),
          MapSearchBar(
            controller: _searchController,
            onFirstResultCoords: [],
          ),
          Positioned(
            right: 28,
            top: 108,
            child: Consumer<AiRecommendationProvider>(
              builder: (context, ai, _) {
                return _AiGradientButton(
                  loading: ai.loading,
                  onTap:
                      ai.loading ? null : () => _sendAiRecommendation(context),
                );
              },
            ),
          ),
          if (_aiCardBody != null)
            Positioned(
              left: 26,
              right: 26,
              top: 132,
              child: _AiNotificationCard(
                body: _aiCardBody!,
                distanceLabel: _distanceToDestination(),
                onTap: _openRouteOptions,
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.18,
            minChildSize: 0.16,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.sheetBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.sheetShadow,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 146,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF777777),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ExploreHeader(
                      hasLocation: _currentPosition != null,
                      locationLoading: _locationLoading,
                    ),
                    const SizedBox(height: 28),
                    if (places.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Nenhum local encontrado',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    _PlaceSection(title: 'Para Explorar', places: places),
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

  String? _distanceToDestination() {
    final meters = _distanceMetersToDestination();
    if (meters == null) return null;

    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  double? _distanceMetersToDestination() {
    final origin = _currentPosition;
    final destination = _routeDestination;
    if (origin == null || destination == null) return null;

    return const Distance().as(
      LengthUnit.Meter,
      origin,
      LatLng(destination.latitude, destination.longitude),
    );
  }

  Future<void> _openRouteOptions() async {
    final destination = _routeDestination;
    final meters = _distanceMetersToDestination();
    if (destination == null || meters == null) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _RouteOptionsSheet(
          place: destination,
          distanceMeters: meters,
          onOpenUber: () => _openRideApp('uber'),
          onOpenNinetyNine: () => _openRideApp('99'),
          onClearRoute: () {
            Navigator.pop(context);
            setState(() {
              _aiCardBody = null;
              _routeDestination = null;
            });
          },
        );
      },
    );
  }

  Future<void> _openRideApp(String app) async {
    final destination = _routeDestination;
    if (destination == null) return;

    final uri = app == 'uber'
        ? Uri.parse(
            'https://m.uber.com/ul/?action=setPickup'
            '&dropoff[latitude]=${destination.latitude}'
            '&dropoff[longitude]=${destination.longitude}'
            '&dropoff[nickname]=${Uri.encodeComponent(destination.name)}',
          )
        : Uri.parse('https://99app.com/');

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  List<Place> _placesInsidePreferenceRadius(List<Place> places) {
    final origin = _currentPosition;
    if (origin == null) return places;

    final filtered = places.where((place) {
      final meters = const Distance().as(
        LengthUnit.Meter,
        origin,
        LatLng(place.latitude, place.longitude),
      );
      return meters <= _maxDistanceKm * 1000;
    }).toList();

    return filtered.isEmpty ? places : filtered;
  }

  List<Place> _rankByUserRadar(List<Place> places) {
    if (_preferenceWeights.isEmpty) return places;

    final ranked = [...places];
    ranked.sort((a, b) {
      final scoreB = _radarScore(b);
      final scoreA = _radarScore(a);
      final scoreComparison = scoreB.compareTo(scoreA);
      if (scoreComparison != 0) return scoreComparison;
      return b.rating.compareTo(a.rating);
    });
    return ranked;
  }

  double _radarScore(Place place) {
    double preference(String key) => _preferenceWeights[key] ?? 0.5;
    double axisScore(bool rightSide, double value) {
      final target = rightSide ? 1.0 : 0.0;
      return 1 - (value - target).abs();
    }

    var score = place.rating;
    score += axisScore(!place.indoor, preference('outdoor')) * 2.0;
    score += axisScore(place.tags.contains('active'), preference('active')) * 1.6;
    score += axisScore(place.nightlife, preference('night')) * 1.6;
    score += axisScore(place.tags.contains('social'), preference('social')) * 1.4;
    score += axisScore(place.tags.contains('new'), preference('novelty')) * 1.2;
    return score;
  }
}

class _AiGradientButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;

  const _AiGradientButton({
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.purpleAeon,
                Color(0xFFBB38DF),
                AppColors.yellowAeon,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.purpleAeon.withValues(alpha: 0.40),
                blurRadius: 18,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.yellowAeon.withValues(alpha: 0.28),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome, color: Colors.black, size: 27),
          ),
        ),
      ),
    );
  }
}

class _AiNotificationCard extends StatelessWidget {
  final String body;
  final String? distanceLabel;
  final VoidCallback onTap;

  const _AiNotificationCard({
    required this.body,
    required this.distanceLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = _extractPlaceTitle(body);
    final subtitle = body.replaceFirst(title, '').trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 118),
        padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/aeonai.png',
              width: 72,
              height: 72,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'AEON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.yellowAeon,
                      fontSize: 17,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (distanceLabel != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.route_outlined,
                          color: Colors.white70,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$distanceLabel ate o local',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          subtitle.isEmpty ? body : subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.18,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractPlaceTitle(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return 'Recomendacao';
    final stop = normalized.indexOf(' combina');
    if (stop > 0) return normalized.substring(0, stop);
    final words = normalized.split(' ');
    return words.take(3).join(' ');
  }
}

class _RouteOptionsSheet extends StatelessWidget {
  final Place place;
  final double distanceMeters;
  final VoidCallback onOpenUber;
  final VoidCallback onOpenNinetyNine;
  final VoidCallback onClearRoute;

  const _RouteOptionsSheet({
    required this.place,
    required this.distanceMeters,
    required this.onOpenUber,
    required this.onOpenNinetyNine,
    required this.onClearRoute,
  });

  @override
  Widget build(BuildContext context) {
    final distanceKm = distanceMeters / 1000;
    final carMinutes = _minutes(distanceKm, 26, extraMinutes: 4);
    final transitMinutes = _minutes(distanceKm, 18, extraMinutes: 10);
    final walkMinutes = _minutes(distanceKm, 4.7);
    final rideMinutes = _minutes(distanceKm, 24, extraMinutes: 5);
    final lowFare = (8 + distanceKm * 2.2 + rideMinutes * 0.25).round();
    final highFare = (12 + distanceKm * 3.4 + rideMinutes * 0.45).round();

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        decoration: const BoxDecoration(
          color: Color(0xFFF0FFF5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 88,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF777777),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              place.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_distanceLabel(distanceMeters)} ate o local',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            _RouteModeTile(
              icon: Icons.directions_car_filled_outlined,
              title: 'Carro',
              subtitle: 'Rota estimada pelo mapa',
              detail: '$carMinutes min',
            ),
            _RouteModeTile(
              icon: Icons.directions_transit_filled_outlined,
              title: 'Transporte publico',
              subtitle: 'Inclui espera media',
              detail: '$transitMinutes min',
            ),
            _RouteModeTile(
              icon: Icons.directions_walk_rounded,
              title: 'A pe',
              subtitle: 'Caminhada aproximada',
              detail: '$walkMinutes min',
            ),
            _RouteModeTile(
              icon: Icons.local_taxi_outlined,
              title: 'Carro por aplicativo',
              subtitle: 'Uber ou 99, media estimada',
              detail: 'R\$$lowFare-R\$$highFare',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenUber,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Uber'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black26),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenNinetyNine,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('99'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black26),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onClearRoute,
                child: const Text(
                  'Limpar rota',
                  style: TextStyle(color: Color(0xFF7B1FA2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _minutes(double distanceKm, double kmh, {int extraMinutes = 0}) {
    return ((distanceKm / kmh) * 60 + extraMinutes)
        .ceil()
        .clamp(1, 999)
        .toInt();
  }

  static String _distanceLabel(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}

class _RouteModeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;

  const _RouteModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE1F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF7B1FA2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            detail,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  final bool hasLocation;
  final bool locationLoading;

  const _ExploreHeader({
    required this.hasLocation,
    required this.locationLoading,
  });

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>().weather;
    final temperature = weather?.temperature.round() ?? 23;
    final locationLabel = locationLoading
        ? 'Localizando...'
        : hasLocation
            ? 'Perto de voce'
            : 'Sao Paulo';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              locationLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Icon(Icons.wb_cloudy_outlined, color: Colors.black, size: 27),
          const SizedBox(width: 8),
          Text(
            '$temperature°',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceSection extends StatelessWidget {
  final String title;
  final List places;

  const _PlaceSection({required this.title, required this.places});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 252,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            padding: const EdgeInsets.only(left: 24, right: 8),
            itemBuilder: (_, index) => PlaceCard(place: places[index]),
          ),
        ),
      ],
    );
  }
}
