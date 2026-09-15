import 'route_coordinate.dart';

class RouteRequest {
  final RouteCoordinate origin;
  final RouteCoordinate destination;

  const RouteRequest({
    required this.origin,
    required this.destination,
  });
}
