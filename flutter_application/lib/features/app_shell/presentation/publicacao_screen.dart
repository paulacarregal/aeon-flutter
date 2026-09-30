import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../feed/presentation/post_provider.dart';
import '../../reviews/data/review_service.dart';
import '../../../shared/routes/route_names.dart';

class PublicacaoScreen extends StatefulWidget {
  final String initialPlaceName;
  final String initialAddress;
  final int initialRating;

  const PublicacaoScreen({
    super.key,
    this.initialPlaceName = '',
    this.initialAddress = '',
    this.initialRating = 0,
  });

  @override
  State<PublicacaoScreen> createState() => _PublicacaoScreenState();
}

class _PublicacaoScreenState extends State<PublicacaoScreen> {
  late final TextEditingController _placeController;
  late final TextEditingController _addressController;
  final _commentController = TextEditingController();
  final _reviewService = ReviewService();
  final Set<String> _selectedTags = {};
  String? _selectedSpendRange;
  late int _rating;
  bool _publishing = false;

  static const _spendRanges = [
    'R\$20-50',
    'R\$51-75',
    'R\$76-100',
    'R\$100+',
  ];

  static const _tagGroups = {
    'Perfil do lugar': [
      'calmo',
      'agitado',
      'social',
      'sozinho',
      'premium',
      'barato',
    ],
    'Experiencia': [
      'cafe',
      'bar',
      'restaurante',
      'cultura',
      'natureza',
      'rooftop',
    ],
    'Contexto': [
      'dia',
      'noite',
      'indoor',
      'ao ar livre',
      'familia',
      'pet friendly',
    ],
  };

  @override
  void initState() {
    super.initState();
    _placeController = TextEditingController(text: widget.initialPlaceName);
    _addressController = TextEditingController(text: widget.initialAddress);
    _rating = widget.initialRating;
  }

  @override
  void dispose() {
    _placeController.dispose();
    _addressController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _publish() async {
    if (_placeController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe local, endereco e uma nota.'),
        ),
      );
      return;
    }

    setState(() => _publishing = true);
    try {
      await _reviewService.publishReview(
        placeName: _placeController.text.trim(),
        address: _addressController.text.trim(),
        rating: _rating,
        comment: _commentController.text.trim(),
        tags: _selectedTags.toList(),
        spendRange: _selectedSpendRange,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review publicada com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao publicar review: $e')),
      );
      setState(() => _publishing = false);
      return;
    }

    if (!mounted) return;
    await context.read<PostProvider>().refresh();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteNames.navigation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FFF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Publicacao',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black12, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Avaliar estabelecimento',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _placeController,
              label: 'Nome do local',
              icon: Icons.storefront_outlined,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _addressController,
              label: 'Endereco ou regiao',
              icon: Icons.place_outlined,
            ),
            const SizedBox(height: 20),
            Row(
              children: List.generate(5, (index) {
                final value = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = value),
                  icon: Icon(
                    value <= _rating ? Icons.star : Icons.star_border,
                    size: 38,
                    color: value <= _rating
                        ? const Color(0xFF9C47B2)
                        : Colors.black45,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Media de gasto por pessoa',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _spendRanges.map((range) {
                final selected = _selectedSpendRange == range;
                return ChoiceChip(
                  label: Text(range),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _selectedSpendRange = selected ? null : range;
                  }),
                  selectedColor: const Color(0xFFE6CBF0),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? const Color(0xFF7B1FA2) : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF7B1FA2)
                          : Colors.black12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              height: 150,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'O que achou da sua experiencia?',
                  hintStyle:
                      TextStyle(color: Colors.black38, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined,
                    color: Colors.white, size: 18),
                label: const Text('Adicionar fotos e videos',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C47B2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Associe aos perfis de recomendacao',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._tagGroups.entries.map(
              (entry) => _TagSection(
                title: entry.key,
                tags: entry.value,
                selectedTags: _selectedTags,
                onTap: _toggleTag,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _publishing ? null : _publish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B1FA2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _publishing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Publicar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  final String title;
  final List<String> tags;
  final Set<String> selectedTags;
  final ValueChanged<String> onTap;

  const _TagSection({
    required this.title,
    required this.tags,
    required this.selectedTags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              final selected = selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: selected,
                onSelected: (_) => onTap(tag),
                selectedColor: const Color(0xFFE6CBF0),
                checkmarkColor: const Color(0xFF7B1FA2),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFF7B1FA2)
                        : Colors.black12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
