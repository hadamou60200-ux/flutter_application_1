import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ride.dart';

class RideDetailPage extends StatelessWidget {
  final Ride ride; // CORRECTION : modèle typé au lieu de Map

  const RideDetailPage({super.key, required this.ride});

  static const Color greenSenRide = Color(0xFF16A34A); // CORRECTION : vert unifié

  Future<void> _ouvrirWhatsApp(BuildContext context) async {
    final message = Uri.encodeComponent(
      "Bonjour ${ride.driverName}, je suis intéressé par votre trajet "
      "${ride.departureCity} - ${ride.arrivalCity} sur SenRide.",
    );
    final url = Uri.parse("https://wa.me/${ride.driverPhone}?text=$message");
    try {
      // CORRECTION : try/catch au lieu d'un throw qui fait planter l'app
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
                onPressed: () => _ouvrirWhatsApp(context),
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text("Contacter le conducteur",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenSenRide,
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
