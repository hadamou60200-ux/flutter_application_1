import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AccueilPage(),
    const Center(child: Text('Mes Trajets')),
    const Center(child: Text('Messages')),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Mes trajets'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. ÉCRAN D'ACCUEIL
// ---------------------------------------------------------------------------
class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // En-tête vert avec message de bienvenue
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Où allez-vous aujourd\'hui ?',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Carte de recherche de trajet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on, color: Colors.green),
                            hintText: 'Départ (ex: Dakar)',
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(),
                        const TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.flag, color: Colors.orange),
                            hintText: 'Arrivée (ex: Thiès)',
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                                  hintText: DateTime.now().toString().split(' ')[0],
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person, color: Colors.grey),
                                  hintText: '1 passager',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'Rechercher un trajet',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. ÉCRAN PROFIL (AVEC PLUSIEURS OPTIONS)
// ---------------------------------------------------------------------------
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // En-tête profil utilisateur
          const Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Utilisateur',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Mon compte',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),

          // Section : Informations
          _buildOptionTile(
            icon: Icons.badge,
            iconColor: Colors.blue,
            title: 'Vérification d\'identité (CNI / Photo)',
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.history,
            iconColor: Colors.purple,
            title: 'Historique des trajets',
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.payment,
            iconColor: Colors.orange,
            title: 'Moyens de paiement (Wave, Orange Money)',
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.settings,
            iconColor: Colors.grey,
            title: 'Paramètres',
            onTap: () {},
          ),

          const Divider(),
          const SizedBox(height: 10),

          // Déconnexion
          _buildOptionTile(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Se déconnecter',
            textColor: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Widget utilitaire pour construire chaque ligne d'option proprement
  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}