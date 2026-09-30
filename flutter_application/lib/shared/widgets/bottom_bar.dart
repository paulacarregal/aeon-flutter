import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54, width: 1.5),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 22),
          ),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '',
        ),
      ],
    );
  }
}
