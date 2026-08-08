import 'package:flutter/material.dart';

void main() {
  runApp(const SenRideApp());
}

class SenRideApp extends StatelessWidget {
  const SenRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Fond gris clair de la maquette
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A), // Vert SenRide
          primary: const Color(0xFF16A34A),
          secondary: const Color(0xFFFF8C00), // Orange SenRide
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: const Text(
          'Accueil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salutation
            const Text(
              'Bonjour 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Où allez-vous aujourd\'hui ?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Carte de recherche de trajet
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Ville de départ
                    Row(
                      children: const [
                        Icon(Icons.circle, color: Color(0xFF16A34A), size: 14),
                        SizedBox(width: 12),
                        Text('Dakar, Sénégal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const Divider(height: 24),

                    // Ville d'arrivée
                    Row(
                      children: const [
                        Icon(Icons.location_on, color: Color(0xFFFF8C00), size: 18),
                        SizedBox(width: 12),
                        Text('Thiès, Sénégal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const Divider(height: 24),

                    // Date & Passagers
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: const [
                              Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('24 Mai 2024', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Container(height: 20, width: 1, color: Colors.grey.shade300),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Icon(Icons.person_outline, size: 18, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('2 passagers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Bouton "Rechercher un trajet"
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text(
                          'Rechercher un trajet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bannière promotionnelle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Voyagez ensemble,',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF9A3412)),
                        ),
                        Text(
                          'économisez davantage',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF9A3412)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.directions_car_filled_sharp, color: Color(0xFFFF8C00), size: 40),
                ],
              ),
            ),
          ],
        ),
      ),

      // Barre de navigation inférieure
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF16A34A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), label: 'Mes trajets'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}