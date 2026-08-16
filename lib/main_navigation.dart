import 'package:flutter/material.dart';
import 'mes_trajets_page.dart'; // Pour importer ta page de trajets
import 'profil_page.dart';
import 'message_page.dart';
import 'package:flutter_application_1/accueil_screen.dart';
// Importe tes fichiers d'écrans ici (ex: accueil, mes_trajets, messages, profil)

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Liste de tes écrans principaux
  final List<Widget> _pages = [
    const AccueilScreen(),
    const MesTrajetsPage(), // Ton fichier mes_trajets_page.dart visible dans tes onglets VS Code
    const MessagesPage(),
    const ProfilPage(), // À remplacer par ton écran de profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Mes trajets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}