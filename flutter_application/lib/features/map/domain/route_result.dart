import 'route_coordinate.dart';

class RouteResult {
  final List<RouteCoordinate> points;
  final double distanceMeters;
  final double durationSeconds;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}
