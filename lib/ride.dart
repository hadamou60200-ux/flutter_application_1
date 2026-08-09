class Ride {
  final String id;
  final String departureCity;
  final String arrivalCity;
  final DateTime departureTime;
  final int price;
  final int availableSeats;
  final String driverName;
  final String? driverPhotoUrl;
  bool isBooked;

  Ride({
    required this.id,
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    required this.price,
    required this.availableSeats,
    required this.driverName,
    this.driverPhotoUrl,
    this.isBooked = false,
  });
}