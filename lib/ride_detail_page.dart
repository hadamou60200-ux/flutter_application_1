import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ride.dart';

class RideDetailPage extends StatelessWidget {
  final Ride ride;
  final String rideId; // ID du document Firestore pour les mises à jour

  const RideDetailPage({super.key, required this.ride, required this.rideId});

  static const Color greenSenRide = Color(0xFF16A34A);

  Future<void> _ouvrirWhatsApp(BuildContext context) async {
    final message = Uri.encodeComponent(
      "Bonjour ${ride.driverName}, je suis intéressé par votre trajet de ${ride.departureCity} à ${ride.arrivalCity} sur SenRide.",
    );
    final url = Uri.parse("https://wa.me/${ride.driverPhone}?text=$message");
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp n\'est pas installé ?')),
        );
      }
    }
  }

  Future<void> _reserverTrajet(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez vous connecter pour réserver.")),
      );
      return;
    }

    if (ride.availableSeats <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Désolé, il n'y a plus de places disponibles.")),
      );
      return;
    }

    try {
      // 1. Enregistrer la réservation avec le driverId indispensable
      await FirebaseFirestore.instance.collection('reservations').add({
        'rideId': rideId,
        'passengerId': user.uid,
        'driverId': ride.driverId, // <-- Indispensable pour le tableau de bord conducteur
        'driverName': ride.driverName,
        'departureCity': ride.departureCity,
        'arrivalCity': ride.arrivalCity,
        'seatsBooked': 1,
        'totalAmount': ride.price,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Mettre à jour les places disponibles dans la collection 'trajets'
      await FirebaseFirestore.instance.collection('trajets').doc(rideId).update({
        'availableSeats': ride.availableSeats - 1,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Demande de réservation envoyée avec succès !"),
            backgroundColor: greenSenRide,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la réservation : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du trajet',
            style: TextStyle(color: Colors.white)),
        backgroundColor: greenSenRide,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.trip_origin, color: greenSenRide),
                      title: Text("Départ : ${ride.departureCity}",
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    ListTile(
                      leading:
                          const Icon(Icons.location_on, color: Colors.red),
                      title: Text("Arrivée : ${ride.arrivalCity}",
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Prix : ${ride.price} FCFA",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Proposé par : ${ride.driverName}",
                style: const TextStyle(fontSize: 16)),
            if (ride.carModel != null) ...[
              const SizedBox(height: 10),
              Text("Véhicule : ${ride.carModel}",
                  style: const TextStyle(fontSize: 16)),
            ],
            const SizedBox(height: 10),
            Text("Places restantes : ${ride.availableSeats}",
                style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: ride.availableSeats > 0 ? () => _reserverTrajet(context) : null,
                icon: const Icon(Icons.bookmark_add, color: Colors.white),
                label: const Text("Réserver ce trajet",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenSenRide,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _ouvrirWhatsApp(context),
                icon: const Icon(Icons.chat, color: greenSenRide),
                label: const Text("Contacter sur WhatsApp",
                    style: TextStyle(fontSize: 16, color: greenSenRide)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: greenSenRide),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}