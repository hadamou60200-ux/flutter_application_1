import 'package:flutter/material.dart';
import 'ride.dart';
import 'ride_card.dart';
import 'detail_page.dart';

class MesTrajetsPage extends StatelessWidget {
  const MesTrajetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Ride> trajetsEnCours = [
      Ride(
        id: '1',
        departureCity: 'Dakar',
        arrivalCity: 'Thiès',
        departureTime: DateTime(2026, 8, 8, 14, 30),
        price: 2500,
        availableSeats: 3,
        driverName: 'Mamadou Diallo',
      ),
    ];

    final List<Ride> historiqueTrajets = [
      Ride(
        id: '2',
        departureCity: 'Saint-Louis',
        arrivalCity: 'Dakar',
        departureTime: DateTime(2026, 8, 8, 8, 0),
        price: 5000,
        availableSeats: 0,
        driverName: 'Fatou Ndiaye',
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mes Trajets',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF16A34A),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'En cours'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Onglet 1 : En cours
            trajetsEnCours.isEmpty
                ? const Center(child: Text('Aucun trajet en cours'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: trajetsEnCours.length,
                    itemBuilder: (context, index) {
                      final ride = trajetsEnCours[index];
                      return RideCard(
                        ride: ride,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RideDetailPage(ride: ride),
                            ),
                          );
                        },
                      );
                    },
                  ),

            // Onglet 2 : Historique
            historiqueTrajets.isEmpty
                ? const Center(child: Text('Aucun historique'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: historiqueTrajets.length,
                    itemBuilder: (context, index) {
                      final ride = historiqueTrajets[index];
                      return RideCard(
                        ride: ride,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RideDetailPage(ride: ride),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}