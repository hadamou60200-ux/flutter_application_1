import 'package:flutter/material.dart';
import 'ride.dart';

class RideDetailPage extends StatelessWidget {
  final Ride ride;

  const RideDetailPage({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${ride.departureCity} → ${ride.arrivalCity}'),
        backgroundColor: const Color(0xFF16A34A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conducteur : ${ride.driverName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Départ : ${ride.departureCity}'),
                    Text('Arrivée : ${ride.arrivalCity}'),
                    const SizedBox(height: 12),
                    Text(
                      'Prix : ${ride.price} FCFA',
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Places disponibles : ${ride.availableSeats}'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text(
                            'Voulez-vous vraiment réserver ce trajet ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                            ),
                            onPressed: () {
                              ride.isBooked = true;
                              Navigator.pop(context);
                              Navigator.pop(context, true);
                            },
                            child: const Text('Confirmer'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'Réserver ce trajet',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}