import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverReservationsScreen extends StatelessWidget {
  const DriverReservationsScreen({super.key});

  static const Color background = Color(0xFF071D24);
  static const Color cardColor = Color(0xFF0E2A33);
  static const Color greenSenRide = Color(0xFF16A34A);

  // Fonction pour accepter la réservation
  Future<void> _accepterReservation(BuildContext context, String reservationId) async {
    try {
      await FirebaseFirestore.instance.collection('reservations').doc(reservationId).update({
        'status': 'accepted',
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Réservation acceptée avec succès."), backgroundColor: greenSenRide),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    }
  }

  // Fonction pour refuser la réservation et restituer la place au trajet
  Future<void> _refuserReservation(BuildContext context, String reservationId, String rideId, int seatsBooked) async {
    try {
      // 1. Mettre le statut de la réservation à 'rejected'
      await FirebaseFirestore.instance.collection('reservations').doc(reservationId).update({
        'status': 'rejected',
      });

      // 2. Récupérer le trajet dans 'trajets' pour restituer les places
      if (rideId.isNotEmpty) {
        final rideDoc = await FirebaseFirestore.instance.collection('trajets').doc(rideId).get();
        if (rideDoc.exists) {
          int currentSeats = rideDoc.data()?['availableSeats'] ?? 0;
          await FirebaseFirestore.instance.collection('trajets').doc(rideId).update({
            'availableSeats': currentSeats + seatsBooked,
          });
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Réservation refusée et place(s) restituée(s).")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text("Demandes reçues", style: TextStyle(color: Colors.white)),
          backgroundColor: cardColor,
        ),
        body: const Center(
          child: Text("Veuillez vous connecter en tant que conducteur.", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Demandes reçues', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('driverId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: greenSenRide));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.white)),
            );
          }

          final reservations = snapshot.data?.docs ?? [];

          if (reservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Aucune demande de réservation pour le moment.",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final resDoc = reservations[index];
              final data = resDoc.data() as Map<String, dynamic>;
              final reservationId = resDoc.id;
              final rideId = data['rideId'] ?? '';
              final departure = data['departureCity'] ?? '';
              final arrival = data['arrivalCity'] ?? '';
              final seats = data['seatsBooked'] ?? 1;
              final amount = data['totalAmount'] ?? 0;
              final status = data['status'] ?? 'pending';

              Color statusColor = Colors.orange;
              String statusText = 'En attente';
              if (status == 'accepted') {
                statusColor = greenSenRide;
                statusText = 'Acceptée';
              } else if (status == 'rejected') {
                statusColor = Colors.red;
                statusText = 'Refusée';
              }

              return Card(
                color: cardColor,
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0x33FFFFFF)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // <-- Corrigé ici
                        children: [
                          Text(
                            "$departure ➔ $arrival",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: Color(0x22FFFFFF)),
                      Text("Places demandées : $seats", style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text("Montant total : $amount FCFA", style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),

                      if (status == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _refuserReservation(context, reservationId, rideId, seats),
                              icon: const Icon(Icons.close, color: Colors.red, size: 18),
                              label: const Text("Refuser", style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () => _accepterReservation(context, reservationId),
                              icon: const Icon(Icons.check, color: Colors.white, size: 18),
                              label: const Text("Accepter", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: greenSenRide),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}