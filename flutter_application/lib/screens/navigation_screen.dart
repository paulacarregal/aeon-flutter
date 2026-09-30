import 'package:flutter/material.dart';

import 'menu_screen.dart';
import 'maps_screen.dart';
import '../screens/favoritos_screen.dart';
import '../screens/perfil_screen.dart';
import '../widgets/bottom_bar.dart';
import '../screens/review_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() =>
      _NavigationScreenState();
}

class _NavigationScreenState
    extends State<NavigationScreen> {

  int selectedIndex = 0;

  final screens = [
    const MenuScreen(),
    const MapsScreen(),
    const ReviewScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),

      bottomNavigationBar: BottomBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}