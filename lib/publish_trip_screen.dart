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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier un trajet'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Point de départ
            TextField(
              controller: _departController,
              decoration: const InputDecoration(
                labelText: 'Ville de départ (ex: Dakar)',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Destination
            TextField(
              controller: _arriveeController,
              decoration: const InputDecoration(
                labelText: 'Ville d\'arrivée (ex: Saint-Louis)',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Date du trajet
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(_selectedDate == null
                  ? 'Date du départ'
                  : 'Date : ${_selectedDate.toString().split(' ')[0]}'),
            ),
            const SizedBox(height: 16),
            
            // Nombre de places
            TextField(
              controller: _placesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de places disponibles',
                prefixIcon: Icon(Icons.airline_seat_recline_normal),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Prix par place (en FCFA)
            TextField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prix par place (ex: 5000 FCFA)',
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Bouton de validation
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                // Pour l'instant, on affiche juste les infos dans la console
                print('Trajet publié : ${_departController.text} -> ${_arriveeController.text}');
              },
              child: const Text('Mettre en ligne le trajet', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
