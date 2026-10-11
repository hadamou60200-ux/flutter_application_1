class Ride {
  final String id;
  final String driverId; // <-- Ajouté pour identifier le propriétaire du trajet
  final String departureCity;
  final String arrivalCity;
  final DateTime departureTime;
  final int price;
  final int availableSeats;
  final String driverName;
  final String? driverPhotoUrl;
  final String? driverPhone;    // Ajouté pour WhatsApp / contact
  final double? driverRating;   // Ajouté pour les étoiles
  final String? carModel;       // Ajouté pour le véhicule
  bool isBooked;

  Ride({
    required this.id,
    required this.driverId, // <-- Requis
    required this.departureCity,
    required this.arrivalCity,
    required this.departureTime,
    required this.price,
    required this.availableSeats,
    required this.driverName,
    this.driverPhotoUrl,
    this.driverPhone,
    this.driverRating,
    this.carModel,
    this.isBooked = false,
  });

  // Factory pour Firestore
  factory Ride.fromMap(String id, Map<String, dynamic> map) {
    return Ride(
      id: id,
      driverId: map['driverId'] ?? '', // <-- Récupération depuis Firestore
      departureCity: map['departureCity'] ?? '',
      arrivalCity: map['arrivalCity'] ?? '',
      departureTime: map['departureTime'] != null 
          ? (map['departureTime'] as dynamic).toDate() 
          : DateTime.now(),
      price: map['price'] ?? 0,
      availableSeats: map['availableSeats'] ?? 1,
      driverName: map['driverName'] ?? '',
      driverPhotoUrl: map['driverPhotoUrl'],
      driverPhone: map['driverPhone'],
      driverRating: map['driverRating'] != null ? (map['driverRating'] as num).toDouble() : null,
      carModel: map['carModel'],
      isBooked: map['isBooked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId, // <-- Sauvegarde dans Firestore
      'departureCity': departureCity,
      'arrivalCity': arrivalCity,
      'departureTime': departureTime,
      'price': price,
      'availableSeats': availableSeats,
      'driverName': driverName,
      'driverPhotoUrl': driverPhotoUrl,
      'driverPhone': driverPhone,
      'driverRating': driverRating,
      'carModel': carModel,
      'isBooked': isBooked,
    };
  }
}