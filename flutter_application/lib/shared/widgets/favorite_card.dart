import 'package:flutter/material.dart';

class FavoriteCard extends StatelessWidget {
  final String nome;
  final double rating;
  final int reviews;
  final String preco;
  final String horario;
  final String image;

  const FavoriteCard({
    super.key,
    required this.nome,
    required this.rating,
    required this.reviews,
    required this.preco,
    required this.horario,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 140,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: image.isNotEmpty
                    ? Image.asset(image, fit: BoxFit.cover, height: 140)
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_outlined,
                            size: 40, color: Colors.grey),
                      ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF9C27B0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        Text(rating.toString(),
                            style: const TextStyle(color: Colors.white)),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ($reviews+)',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Abre às $horario',
                        style: const TextStyle(color: Colors.white)),
                    Text(preco,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
