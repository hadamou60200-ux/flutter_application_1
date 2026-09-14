import 'package:flutter/material.dart';

class PublishTripScreen extends StatefulWidget {
  const PublishTripScreen({super.key});

  @override
  State<PublishTripScreen> createState() => _PublishTripScreenState();
}

class _PublishTripScreenState extends State<PublishTripScreen> {
  final _departController = TextEditingController();
  final _arriveeController = TextEditingController();
  final _prixController = TextEditingController();
  final _placesController = TextEditingController();
  DateTime? _selectedDate;

  static const Color greenSenRide = Color(0xFF16A34A);

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    _prixController.dispose();
    _placesController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _publier() {
    final depart = _departController.text.trim();
    final arrivee = _arriveeController.text.trim();
    final prix = int.tryParse(_prixController.text.trim());
    final places = int.tryParse(_placesController.text.trim());

    if (depart.isEmpty || arrivee.isEmpty) {
      _showSnackBar('Renseigne les villes de départ et d\'arrivée.');
      return;
    }
    if (_selectedDate == null) {
      _showSnackBar('Choisis une date de départ.');
      return;
    }
    if (places == null || places < 1 || places > 8) {
      _showSnackBar('Nombre de places invalide (1 à 8).');
      return;
    }
    if (prix == null || prix <= 0) {
      _showSnackBar('Prix invalide.');
      return;
    }

    // TODO: Enregistrer le trajet dans Firebase Firestore
    _showSnackBar('Trajet validé avec succès !');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier un trajet'),
        backgroundColor: greenSenRide,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _departController,
              decoration: const InputDecoration(
                labelText: 'Ville de départ',
                prefixIcon: Icon(Icons.location_on, color: greenSenRide),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _arriveeController,
              decoration: const InputDecoration(
                labelText: 'Ville d\'arrivée',
                prefixIcon: Icon(Icons.flag, color: greenSenRide),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _placesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de places (1-8)',
                prefixIcon: Icon(Icons.person, color: greenSenRide),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prix par place (FCFA)',
                prefixIcon: Icon(Icons.money, color: greenSenRide),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: greenSenRide,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _publier,
              child: const Text(
                'Publier le trajet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}