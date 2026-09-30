import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  int _currentImage = 0;

  final List<String> _images = [
    'assets/images/places/bar_tan_tan_1.jpg',
    'assets/images/places/bar_tan_tan_2.jpg',
    'assets/images/places/bar_tan_tan_3.jpg',
  ];

  Future<void> _abrirRota() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=-23.5365,-46.6780',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EFE8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 320,
                            viewportFraction: 1,
                            enableInfiniteScroll: true,
                            onPageChanged: (index, _) =>
                                setState(() => _currentImage = index),
                          ),
                          items: _images.map((image) {
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        _FullImageScreen(image: image)),
                              ),
                              child: Image.asset(image,
                                  width: double.infinity, fit: BoxFit.cover),
                            );
                          }).toList(),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_images.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentImage == index ? 14 : 10,
                          height: _currentImage == index ? 14 : 10,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImage == index
                                ? Colors.amber
                                : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BAR TAN TAN',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text(
                            'Sugerido porque você está próximo do local e costuma visitar ambientes agitados durante a noite.',
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              _InfoChip(icon: Icons.route, text: '05 min'),
                              _InfoChip(
                                  icon: Icons.local_fire_department,
                                  text: 'Moderado'),
                              _InfoChip(
                                  icon: Icons.attach_money, text: '\$\$'),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Text('Avaliações dos usuários',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: const [
                              Text('4.8',
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 10),
                              Icon(Icons.star, color: Colors.amber),
                              Icon(Icons.star, color: Colors.amber),
                              Icon(Icons.star, color: Colors.amber),
                              Icon(Icons.star, color: Colors.amber),
                              Icon(Icons.star, color: Colors.amber),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const _ReviewTile(
                              name: 'Cláudia M.',
                              comment:
                                  'Música excelente e ambiente muito agradável.'),
                          const _ReviewTile(
                              name: 'Matheus C.',
                              comment: 'Ótimas bebidas e atendimento rápido.'),
                          const _ReviewTile(
                              name: 'Amanda R.',
                              comment:
                                  'Lugar bonito e muito movimentado nos finais de semana.'),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _abrirRota,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Ir agora',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.yellowAccent,
      avatar: Icon(icon, size: 18),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final String comment;

  const _ReviewTile({required this.name, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name),
        subtitle: Text(comment),
      ),
    );
  }
}

class _FullImageScreen extends StatelessWidget {
  final String image;

  const _FullImageScreen({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Image.asset(image),
          ),
        ),
      ),
    );
  }
}
