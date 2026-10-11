import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'rate_user_screen.dart'; // Importation de l'écran de notation
import 'payment_screen.dart'; // Importation de l'écran de paiement officiel

class MesReservationsScreen extends StatelessWidget {
  const MesReservationsScreen({super.key});

  static const Color background = Color(0xFF071D24);
  static const Color cardColor = Color(0xFF0E2A33);
  static const Color greenSenRide = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text("Mes Réservations", style: TextStyle(color: Colors.white)),
          backgroundColor: cardColor,
        ),
        body: const Center(
          child: Text("Veuillez vous connecter pour voir vos réservations.", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Mes Réservations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Écoute des réservations liées au passager connecté
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('passengerId', isEqualTo: user.uid)
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
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Vous n'avez aucune réservation pour le moment.",
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
              final departure = data['departureCity'] ?? '';
              final arrival = data['arrivalCity'] ?? '';
              final driverName = data['driverName'] ?? 'Conducteur';
              final driverId = data['driverId'] ?? '';
              final trajetId = data['trajetId'] ?? '';
              final seats = data['seatsBooked'] ?? 1;
              final amount = (data['totalAmount'] ?? 0).toDouble();
              final status = data['status'] ?? 'pending';
              final paymentStatus = data['paymentStatus'] ?? 'unpaid';

              // Couleur et libellé selon le statut
              Color statusColor = Colors.orange;
              String statusText = 'En attente de validation';
              if (status == 'accepted') {
                statusColor = greenSenRide;
                statusText = 'Réservation Acceptée ✅';
              } else if (status == 'rejected') {
                statusColor = Colors.red;
                statusText = 'Réservation Refusée ❌';
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Text("Conducteur : $driverName", style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text("Places réservées : $seats", style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text("Montant : $amount FCFA", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      
                      // Actions visibles si la réservation est acceptée
                      if (status == 'accepted') ...[
                        const SizedBox(height: 12),
                        
                        // Bouton de paiement officiel ou badge de succès
                        if (paymentStatus != 'paid') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(
                                      trajetId: trajetId,
                                      reservationId: reservationId,
                                      amount: amount,
                                      driverName: driverName,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.payment, color: Colors.white, size: 18),
                              label: const Text(
                                "Payer le trajet (Wave / Orange)",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenSenRide,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: greenSenRide.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: greenSenRide),
                            ),
                            child: const Center(
                              child: Text(
                                "Payé avec succès ✅",
                                style: TextStyle(color: greenSenRide, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Bouton de notation du conducteur
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RateUserScreen(
                                    trajetId: trajetId,
                                    destinataireId: driverId,
                                    destinataireNom: driverName,
                                    isRatingDriver: true,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.star, color: Colors.amber, size: 18),
                            label: const Text(
                              "Noter le conducteur",
                              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.amber, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
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