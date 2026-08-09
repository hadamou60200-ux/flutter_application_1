import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilise la même couleur que celle définie pour SenRide dans ton accueil_page.dart
    const Color greenSenRide = Color(0xFF4CAF50); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: greenSenRide,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section en-tête du profil
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: greenSenRide,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: greenSenRide),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Utilisateur SenRide",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Liste des options du profil
            _buildOptionTile(Icons.person_outline, "Informations personnelles"),
            _buildOptionTile(Icons.history, "Mes trajets"),
            _buildOptionTile(Icons.payment, "Paiements"),
            _buildOptionTile(Icons.settings, "Paramètres"),
             const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  // Action de déconnexion
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF4CAF50)),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
      ),
    );
  }
}