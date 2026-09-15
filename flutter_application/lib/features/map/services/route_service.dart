import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/route_coordinate.dart';
import '../domain/route_request.dart';
import '../domain/route_result.dart';

class RouteService {
  static const String _baseUrl = 'https://router.project-osrm.org';

  Future<RouteResult> calculateRoute(RouteRequest request) async {
    final origin = request.origin;
    final destination = request.destination;

    final uri = Uri.parse(
      '$_baseUrl/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao calcular rota. HTTP ${response.statusCode}.',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['code'] != 'Ok') {
      throw Exception(
        'Serviço de rota não conseguiu calcular o percurso.',
      );
    }

    final routes = data['routes'] as List<dynamic>?;

    if (routes == null || routes.isEmpty) {
      throw Exception('Nenhuma rota encontrada.');
    }

    final route = routes.first as Map<String, dynamic>;

    final distanceMeters = (route['distance'] as num?)?.toDouble();
    final durationSeconds = (route['duration'] as num?)?.toDouble();
    final geometry = route['geometry'] as Map<String, dynamic>?;
    final coordinates = geometry?['coordinates'] as List<dynamic>?;

    if (distanceMeters == null ||
        durationSeconds == null ||
        coordinates == null ||
        coordinates.isEmpty) {
      throw Exception('Resposta de rota incompleta.');
    }

    final points = coordinates.map<RouteCoordinate>((coordinate) {
      final values = coordinate as List<dynamic>;

      return RouteCoordinate(
        longitude: (values[0] as num).toDouble(),
        latitude: (values[1] as num).toDouble(),
      );
    }).toList();

    final lastPoint = points.last;

    print('===== OSRM ROUTE DEBUG =====');
    print(
      'DESTINO SOLICITADO: '
      '${destination.latitude}, ${destination.longitude}',
    );
    print(
      'ULTIMO PONTO OSRM: '
      '${lastPoint.latitude}, ${lastPoint.longitude}',
    );
    print('PONTOS DA ROTA: ${points.length}');
    print('DISTANCIA OSRM: $distanceMeters');
    print('DURACAO OSRM: $durationSeconds');
    print('===== FIM OSRM ROUTE DEBUG =====');

    return RouteResult(
      points: points,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
    );
  }
}