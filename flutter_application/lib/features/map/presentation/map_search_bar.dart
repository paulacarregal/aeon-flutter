import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './place_provider.dart';

class MapSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final List<double Function()> onFirstResultCoords;

  const MapSearchBar({
    super.key,
    required this.controller,
    required this.onFirstResultCoords,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 26,
      right: 26,
      child: Container(
        height: 46,
        padding: const EdgeInsets.only(left: 18, right: 6),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: (query) =>
              context.read<PlaceProvider>().search(query),
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            hintText: 'Pesquisar...',
            hintStyle: TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search, color: Colors.white, size: 32),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}
