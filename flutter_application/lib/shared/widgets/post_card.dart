import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../features/feed/domain/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final bool liked;
  final bool saved;
  final int displayLikes;
  final VoidCallback onLike;
  final VoidCallback onSave;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.liked,
    required this.saved,
    required this.displayLikes,
    required this.onLike,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.nome,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(post.info,
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                5,
                (i) => Icon(Icons.star,
                    size: 18,
                    color: i < post.rating
                        ? Colors.amber
                        : Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 10),
            Text(post.texto,
                style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 220,
                    viewportFraction: 1,
                    enableInfiniteScroll: true,
                  ),
                  items: post.imagens.map((image) {
                    return Image.asset(image,
                        width: double.infinity, fit: BoxFit.cover);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 34,
                    minHeight: 34,
                  ),
                  onPressed: onLike,
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : Colors.black54,
                  ),
                ),
                const SizedBox(width: 6),
                Text('$displayLikes Curtidas'),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 34,
                    minHeight: 34,
                  ),
                  onPressed: onSave,
                  icon: Icon(
                    saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? const Color(0xFF7B1FA2) : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
