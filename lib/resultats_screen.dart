import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ride.dart';
import 'ride_detail_page.dart';

class ResultatsScreen extends StatelessWidget {
  final String villeDepart;
  final String villeArrivee;
  final DateTime dateVoyage;

  const ResultatsScreen({
    super.key,
    required this.villeDepart,
    required this.villeArrivee,
    required this.dateVoyage,
  });

  static const Color greenSenRide = Color(0xFF16A34A);

  String _formatDate(DateTime date) {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071D24), // Fond bleu nuit SenRide
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E2A33),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$villeDepart → $villeArrivee',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Prévu le ${_formatDate(dateVoyage)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      // Utilisation d'un StreamBuilder pour écouter Firestore en temps réel
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trajets')
            .where('villeDepart', isEqualTo: villeDepart)
            .where('villeArrivee', isEqualTo: villeArrivee)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: greenSenRide));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun trajet trouvé pour cet itinéraire.',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              // Conversion sécurisée des données Firestore vers ton modèle Ride
              final Timestamp? timestamp = data['dateHeureDepart'];
              final DateTime departureDateTime = timestamp?.toDate() ?? DateTime.now();

              final ride = Ride(
                id: docs[index].id,
                departureCity: data['villeDepart'] ?? '',
                arrivalCity: data['villeArrivee'] ?? '',
                departureTime: departureDateTime,
                price: data['prix'] ?? 0,
                availableSeats: data['places'] ?? 1,
                driverName: data['driverName'] ?? 'Conducteur SenRide',
                driverPhone: data['driverPhone'] ?? '221770000000',
                carModel: data['carModel'] ?? 'Véhicule standard',
                driverRating: 5.0,
              );

              return _TrajetCard(ride: ride);
            },
          );
        },
      ),
    );
  }
}

class _TrajetCard extends StatelessWidget {
  final Ride ride;
  const _TrajetCard({required this.ride});

  static const Color greenSenRide = Color(0xFF16A34A);

  void _ouvrirDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RideDetailPage(ride: ride)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formatage de l'heure de départ (ex: 14:30)
    final String heureFormatee = '${ride.departureTime.hour.toString().padLeft(2, '0')}:${ride.departureTime.minute.toString().padLeft(2, '0')}';

    return Card(
      color: const Color(0xFF0E2A33), // Couleur des cartes SenRide
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x33FFFFFF)), // Bordure discrète
      ),
      child: InkWell(
        onTap: () => _ouvrirDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF10323D),
                    child: Icon(Icons.person, color: Colors.white70),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.driverName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${ride.driverRating ?? "-"}',
                              style: const TextStyle(color: Colors.white60, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20, color: Color(0x22FFFFFF)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF38BDF8), size: 16),
                          const SizedBox(width: 6),
                          Text('Départ à $heureFormatee',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${ride.carModel ?? "Véhicule"} • ${ride.availableSeats} places dispo',
                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${ride.price} FCFA',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: greenSenRide)),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: () => _ouvrirDetails(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenSenRide,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Réserver',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}