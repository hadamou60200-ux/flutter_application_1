import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RideDetailPage extends StatelessWidget {
  final Map<String, dynamic> rideData; // Les données du trajet sélectionné

  const RideDetailPage({super.key, required this.rideData});

  // Fonction pour lancer WhatsApp
  Future<void> _ouvrirWhatsApp(String telephone, String message) async {
    final url = Uri.parse("https://wa.me/$telephone?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossible d\'ouvrir WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Couleur principale SenRide
    const Color greenSenRide = Color(0xFF4CAF50);

    // Récupération des données (adaptez les clés selon votre base de données)
    final String depart = rideData['depart'] ?? 'Départ inconnu';
    final String arrivee = rideData['arrivee'] ?? 'Arrivée inconnue';
    final String prix = rideData['prix'] ?? '0';
    final String conducteur = rideData['conducteur'] ?? 'Conducteur';
    final String telephone = rideData['telephone'] ?? '221000000000'; // Numéro par défaut

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du trajet'),
        backgroundColor: greenSenRide,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte d'itinéraire
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.trip_origin, color: greenSenRide),
                      title: Text("Départ : $depart", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text("Arrivée : $arrivee", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Informations prix et conducteur
            Text("Prix : $prix FCFA", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Proposé par : $conducteur", style: const TextStyle(fontSize: 16)),
            
            const Spacer(),

            // Bouton WhatsApp
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  _ouvrirWhatsApp(
                    telephone, 
                    "Bonjour $conducteur, je suis intéressé par votre trajet $depart - $arrivee sur SenRide."
                  );
                },
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text(
                  "Contacter le conducteur",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenSenRide,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}