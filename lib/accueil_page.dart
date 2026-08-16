import 'package:flutter/material.dart';
import 'register_page.dart'; // Importation de votre page d'inscription KYC
import 'main_navigation.dart'; // Importation de votre page principale

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  // Variable pour suivre si l'inscription a été validée
  bool _isRegistered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenue sur SenRide'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.directions_car,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                'Votre solution de covoiturage au meilleur prix',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Affiche le bouton SEULEMENT si _isRegistered est faux
              if (!_isRegistered)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    // On attend le retour de la page d'inscription
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );

                    // Si l'inscription réussit, on bascule vers l'application principale
                    if (result == true) {
                      setState(() {
                        _isRegistered = true;
                      });

                      // Redirection vers l'application principale en supprimant l'accueil de l'historique
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavigation()),
                      );
                    }
                  },
                  icon: const Icon(Icons.security, color: Colors.white),
                  label: const Text(
                    "Tester l'Inscription Sécurisée",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}