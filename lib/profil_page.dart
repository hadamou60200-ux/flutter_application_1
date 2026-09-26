import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Import indispensable

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // CORRECTION : même vert que partout ailleurs
  static const Color greenSenRide = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: greenSenRide,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: greenSenRide,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: greenSenRide),
                  ),
                  const SizedBox(height: 12),
                  const Text('Ousmane Fall',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('ousmane.fall@email.com',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  // Note du conducteur
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('4.8/5',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      const Text('(12 avis)',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Options
            _buildOptionTile(
              icon: Icons.edit,
              title: 'Modifier le profil',
              onTap: () {},
            ),
            _buildOptionTile(
              icon: Icons.directions_car,
              title: 'Mon véhicule',
              onTap: () {},
            ),
            _buildOptionTile(
              icon: Icons.payment,
              title: 'Paiements',
              onTap: () {},
            ),
            _buildOptionTile(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {},
            ),
            _buildOptionTile(
              icon: Icons.help,
              title: 'Aide & Support',
              onTap: () {},
            ),
            const SizedBox(height: 20),

            // Déconnexion
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Déconnexion de Firebase Auth
                    await FirebaseAuth.instance.signOut();
                    // Grâce au StreamBuilder dans le main.dart, 
                    // l'application basculera automatiquement sur le LoginScreen.
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Se déconnecter',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(icon, color: greenSenRide),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}