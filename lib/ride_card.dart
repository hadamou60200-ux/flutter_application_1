import 'package:flutter/material.dart';
import 'ride.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap; // Votre callback, déjà là

  const RideCard({
    super.key,
    required this.ride,
    this.onTap, // Votre callback, déjà là
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // C'est ici que l'on rend la carte cliquable
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap, // On connecte le clic au callback passé en paramètre
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ville de départ -> Ville d'arrivée
                  Text(
                    '${ride.departureCity} → ${ride.arrivalCity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Prix
                  Text(
                    '${ride.price} FCFA',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A), // Vert
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Informations chauffeur et places
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chauffeur: ${ride.driverName}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    '${ride.availableSeats} places',
                    style: TextStyle(color: Colors.grey[700]),
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