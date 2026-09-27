import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'become_driver_page.dart';
import 'vehicle_management_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  static const Color greenSenRide = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: greenSenRide,
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text('Aucun utilisateur connecté'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: greenSenRide));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Aucune donnée trouvée pour cet utilisateur dans Firestore. Veuillez vous réinscrire ou vérifier l\'ID.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

                String prenom = data['prenom'] ?? 'Utilisateur';
                String nom = data['nom'] ?? '';
                String email = data['email'] ?? currentUser.email ?? '';
                bool isConducteur = data['isConducteur'] ?? false;
                String statutConducteur = data['statutConducteur'] ?? '';

                return SingleChildScrollView(
                  child: Column(
                    children: [
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
                            Text('$prenom $nom',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(email, style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isConducteur ? Colors.amber[800] : Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isConducteur
                                    ? (statutConducteur == 'en_attente'
                                        ? 'Conducteur (En attente de validation)'
                                        : 'Conducteur Validé')
                                    : 'Passager (Chercheur de trajet)',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildOptionTile(
                        icon: Icons.edit,
                        title: 'Modifier le profil',
                        onTap: () {},
                      ),
                      if (!isConducteur) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Card(
                            elevation: 3,
                            color: Colors.amber[50],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: const Icon(Icons.directions_car, color: Colors.amber),
                              title: const Text('Devenir Conducteur',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                              subtitle: const Text('Proposez vos trajets au Sénégal', style: TextStyle(fontSize: 12)),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.amber),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const BecomeDriverPage()),
                                );
                              },
                            ),
                          ),
                        ),
                      ] else ...[
                        _buildOptionTile(
                          icon: Icons.directions_car,
                          title: 'Mon véhicule & Permis',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const VehicleManagementPage()),
                            );
                          },
                        ),
                      ],
                      _buildOptionTile(
                        icon: Icons.payment,
                        title: 'Paiements (Wave / Orange Money)',
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
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
                );
              },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(icon, color: greenSenRide),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}