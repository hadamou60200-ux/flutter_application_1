import 'package:flutter/material.dart';
import 'ride.dart';
import 'ride_detail_page.dart';

class ResultatsScreen extends StatelessWidget {
  final String villeDepart;
  final String villeArrivee;

  const ResultatsScreen({
    super.key,
    this.villeDepart = 'Dakar',
    this.villeArrivee = 'Thiès',
  });

  static const Color greenSenRide = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    // Données de démo — à remplacer par Firestore ensuite
    final List<Ride> trajets = [
      Ride(
        id: '1',
        departureCity: villeDepart,
        arrivalCity: villeArrivee,
        departureTime: DateTime.now().add(const Duration(hours: 3)),
        price: 2500,
        availableSeats: 3,
        driverName: 'Mamadou D.',
        driverPhone: '221770000000',
        carModel: 'Toyota RAV4',
        driverRating: 4.8,
      ),
      Ride(
        id: '2',
        departureCity: villeDepart,
        arrivalCity: villeArrivee,
        departureTime: DateTime.now().add(const Duration(hours: 5)),
        price: 2500,
        availableSeats: 2,
        driverName: 'Fatou Ndoye',
        driverPhone: '221780000000',
        carModel: 'Hyundai Tucson',
        driverRating: 4.6,
      ),
      Ride(
        id: '3',
        departureCity: villeDepart,
        arrivalCity: villeArrivee,
        departureTime: DateTime.now().add(const Duration(hours: 8)),
        price: 2500,
        availableSeats: 4,
        driverName: 'Ibrahima S.',
        driverPhone: '221760000000',
        carModel: 'Peugeot 3008',
        driverRating: 4.9,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: greenSenRide,
        title: Text('$villeDepart → $villeArrivee',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trajets.length,
        itemBuilder: (context, index) =>
            _TrajetCard(ride: trajets[index]),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    backgroundColor: Color(0xFFE2E8F0),
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.driverName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${ride.driverRating ?? "-"}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ride.departureCity} → ${ride.arrivalCity}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ride.carModel ?? "Véhicule"} • ${ride.availableSeats} places',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
