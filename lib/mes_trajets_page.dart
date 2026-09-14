import 'package:flutter/material.dart';
import 'ride.dart';
import 'ride_card.dart';
import 'ride_detail_page.dart';

class MesTrajetsPage extends StatelessWidget {
  const MesTrajetsPage({super.key});

  static const Color greenSenRide = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    // Données de démo — à remplacer par Firestore
    final List<Ride> trajetsEnCours = [
      Ride(
        id: '1',
        departureCity: 'Dakar',
        arrivalCity: 'Thiès',
        departureTime: DateTime.now().add(const Duration(days: 1)),
        price: 2500,
        availableSeats: 3,
        driverName: 'Mamadou Diallo',
        driverPhone: '221770000000',
        carModel: 'Toyota RAV4',
        driverRating: 4.8,
      ),
    ];

    final List<Ride> historiqueTrajets = [
      Ride(
        id: '2',
        departureCity: 'Saint-Louis',
        arrivalCity: 'Dakar',
        departureTime: DateTime.now().subtract(const Duration(days: 7)),
        price: 5000,
        availableSeats: 0,
        driverName: 'Fatou Ndiaye',
        driverPhone: '221780000000',
        carModel: 'Hyundai Tucson',
        driverRating: 4.6,
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Trajets',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: greenSenRide,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'En cours'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRideList(context, trajetsEnCours, 'Aucun trajet en cours'),
            _buildRideList(context, historiqueTrajets, 'Aucun historique'),
          ],
        ),
      ),
    );
  }

  // CORRECTION : code de liste factorisé (plus de duplication)
  Widget _buildRideList(
      BuildContext context, List<Ride> rides, String emptyMessage) {
    if (rides.isEmpty) return Center(child: Text(emptyMessage));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];
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
    );
  }
}
