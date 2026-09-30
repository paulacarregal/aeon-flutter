class Place {
  final String id;
  final String name;
  final double rating;
  final String priceRange;
  final String horario;
  final String distancia;
  final String image;
  final double latitude;
  final double longitude;
  final Set<String> tags;
  final int priceLevel;
  final bool indoor;
  final bool daytime;
  final bool nightlife;

  Place({
    this.id = '',
    required this.name,
    required this.rating,
    required this.priceRange,
    required this.horario,
    required this.distancia,
    required this.image,
    required this.latitude,
    required this.longitude,
    Set<String>? tags,
    this.priceLevel = 2,
    this.indoor = true,
    this.daytime = true,
    this.nightlife = false,
  }) : tags = tags ?? const {};

  factory Place.fromMap(String id, Map<String, dynamic> map) {
    return Place(
      id: id,
      name: map['name'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      priceRange: map['priceRange'] as String? ?? '',
      horario: map['horario'] as String? ?? '',
      distancia: map['distancia'] as String? ?? '',
      image: map['image'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      tags: Set<String>.from(map['tags'] as List? ?? const []),
      priceLevel: (map['priceLevel'] as num?)?.toInt() ?? 2,
      indoor: map['indoor'] as bool? ?? true,
      daytime: map['daytime'] as bool? ?? true,
      nightlife: map['nightlife'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'priceRange': priceRange,
      'horario': horario,
      'distancia': distancia,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags.toList(),
      'priceLevel': priceLevel,
      'indoor': indoor,
      'daytime': daytime,
      'nightlife': nightlife,
    };
  }
}
