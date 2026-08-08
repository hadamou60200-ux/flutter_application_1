class Ride {
  final String id;
  final String departureCity;
  final String arrivalCity;
  final DateTime departureTime;
  final int price; // En FCFA
  final int availableSeats;
  final String driverName;
  final String? driverPhotoUrl;

  Ride({
    required this.id,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    required this.price,
    required this.availableSeats,
    required this.driverName,
    this.driverPhotoUrl,
  });
}

// Liste de trajets fictifs pour la démonstration
final List<Ride> mockRides = [
  Ride(
    id: '1',
    departureCity: 'Dakar',
    arrivalCity: 'Thiès',
    departureTime: DateTime.now().add(const Duration(hours: 2)),
    price: 2500,
    availableSeats: 3,
    driverName: 'Moussa Diop',
  ),
  Ride(
    id: '2',
    departureCity: 'Dakar',
    arrivalCity: 'Saint-Louis',
    departureTime: DateTime.now().add(const Duration(hours: 4)),
    price: 6000,
    availableSeats: 2,
    driverName: 'Awa Ndiaye',
  ),
  Ride(
    id: '3',
    departureCity: 'Mbour',
    arrivalCity: 'Dakar',
    departureTime: DateTime.now().add(const Duration(hours: 6)),
    price: 3000,
    availableSeats: 4,
    driverName: 'Ousmane Sow',
  ),
];