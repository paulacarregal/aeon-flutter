import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'publicacao_screen.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  static const _places = <VisitedPlace>[
    VisitedPlace(
      name: 'Bar Tan Tan',
      visitedLabel: 'Voce visitou ha 4 dias',
      address: 'Rua Fradique Coutinho, 153 - Pinheiros',
      image: 'assets/images/places/bar_tan_tan_1.jpg',
    ),
    VisitedPlace(
      name: 'Cafe Central',
      visitedLabel: 'Voce visitou ontem',
      address: 'Centro de Sao Paulo',
      image: 'assets/images/places/cafe_central_2.png',
    ),
    VisitedPlace(
      name: 'Parque Ibirapuera',
      visitedLabel: 'Voce visitou ha 1 semana',
      address: 'Av. Pedro Alvares Cabral - Vila Mariana',
      image: 'assets/images/places/parque_verde.jpg',
    ),
  ];

  void _openSearch(BuildContext context, {int initialRating = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceSearchScreen(initialRating: initialRating),
      ),
    );
  }

  void _openPublication(
    BuildContext context,
    VisitedPlace place, {
    int initialRating = 0,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicacaoScreen(
          initialPlaceName: place.name,
          initialAddress: place.address,
          initialRating: initialRating,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: Stack(
        children: [
          const _ReviewMapBackdrop(),
          DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.28,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(34),
                ),
                child: ColoredBox(
                  color: const Color(0xFF101010),
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 14),
                      Center(
                        child: Container(
                          width: 74,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFF777777),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Publicar',
                            style: TextStyle(
                              color: Color(0xFFEDEDED),
                              fontSize: 36,
                              height: 1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _SearchContributionButton(
                          onTap: () => _openSearch(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFF4A4A4A),
                      ),
                      const SizedBox(height: 14),
                      ...List.generate(_places.length, (index) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            0,
                            24,
                            index == _places.length - 1 ? 122 : 48,
                          ),
                          child: _PlaceContributionItem(
                            place: _places[index],
                            onTap: () => _openPublication(
                              context,
                              _places[index],
                            ),
                            onReview: (rating) => _openPublication(
                              context,
                              _places[index],
                              initialRating: rating,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PlaceSearchScreen extends StatefulWidget {
  final int initialRating;

  const PlaceSearchScreen({
    super.key,
    this.initialRating = 0,
  });

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final _searchController = TextEditingController();
  static const _result = VisitedPlace(
    name: 'Bar Tan Tan',
    visitedLabel: 'Bar e restaurante',
    address: 'Rua Fradique Coutinho, 153 - Pinheiros',
    image: 'assets/images/places/bar_tan_tan_1.jpg',
  );

  bool get _showResult {
    final query = _searchController.text.trim().toLowerCase();
    return query.isEmpty || 'bar tan tan'.contains(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectPlace() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PublicacaoScreen(
          initialPlaceName: _result.name,
          initialAddress: _result.address,
          initialRating: widget.initialRating,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Pesquisar lugar',
                        hintStyle:
                            const TextStyle(color: Color(0xFFA7ADB0)),
                        prefixIcon: const Icon(Icons.search,
                            color: Color(0xFFA7ADB0)),
                        filled: true,
                        fillColor: const Color(0xFF172224),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF29383C)),
            Expanded(
              child: _showResult
                  ? ListView(
                      children: [
                        ListTile(
                          onTap: _selectPlace,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              _result.image,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            _result.name,
                            style: const TextStyle(
                              color: Color(0xFFEDEDED),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            _result.address,
                            style: const TextStyle(color: Color(0xFFA7ADB0)),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: Color(0xFFA7ADB0)),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Nenhum lugar encontrado',
                        style: TextStyle(color: Color(0xFFA7ADB0)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisitedPlace {
  const VisitedPlace({
    required this.name,
    required this.visitedLabel,
    required this.address,
    required this.image,
  });

  final String name;
  final String visitedLabel;
  final String address;
  final String image;
}

class _SearchContributionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchContributionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF172224),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF29383C)),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Color(0xFFA7ADB0)),
            SizedBox(width: 12),
            Text(
              'Fazer avaliacao',
              style: TextStyle(
                color: Color(0xFFEDEDED),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceContributionItem extends StatelessWidget {
  const _PlaceContributionItem({
    required this.place,
    required this.onTap,
    required this.onReview,
  });

  final VisitedPlace place;
  final VoidCallback onTap;
  final ValueChanged<int> onReview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  place.image,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFEDEDED),
                        fontSize: 27,
                        height: 1.08,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.visitedLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFA9A9A9),
                        fontSize: 23,
                        height: 1.05,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFFECECEC),
                  size: 34,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _RatingCard(onReview: onReview),
      ],
    );
  }
}

class _RatingCard extends StatefulWidget {
  final ValueChanged<int> onReview;

  const _RatingCard({required this.onReview});

  @override
  State<_RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard> {
  int _rating = 0;

  void _rate(int value) {
    setState(() => _rating = value);
    widget.onReview(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF172224),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avalie este lugar',
            style: TextStyle(
              color: Color(0xFFEAEAEA),
              fontSize: 26,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final selected = starValue <= _rating;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _rate(starValue),
                child: Icon(
                  selected ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 52,
                  color: selected
                      ? const Color(0xFF8DE9F4)
                      : const Color(0xFFA7ADB0),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ReviewMapBackdrop extends StatelessWidget {
  const _ReviewMapBackdrop();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(-23.5505, -46.6333),
          initialZoom: 13.2,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'br.com.aeon.app',
          ),
          MarkerLayer(
            markers: const [
              Marker(
                point: LatLng(-23.5665, -46.6901),
                width: 40,
                height: 40,
                child: Icon(
                  Icons.location_on,
                  color: Color(0xFF7B1FA2),
                  size: 32,
                ),
              ),
              Marker(
                point: LatLng(-23.5505, -46.6333),
                width: 40,
                height: 40,
                child: Icon(
                  Icons.location_on,
                  color: Color(0xFF7B1FA2),
                  size: 32,
                ),
              ),
              Marker(
                point: LatLng(-23.5874, -46.6576),
                width: 40,
                height: 40,
                child: Icon(
                  Icons.location_on,
                  color: Color(0xFF7B1FA2),
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
