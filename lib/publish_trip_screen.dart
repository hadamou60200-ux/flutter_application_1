import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Tes couleurs SenRide
class SenRideColors {
  static const background = Color(0xFF071D24);
  static const card = Color(0xFF0E2A33);
  static const field = Color(0xFF10323D);
  static const border = Color(0x33FFFFFF);
  static const green = Color(0xFF16A34A);
  static const aqua = Color(0xFF38BDF8);
  static const yellow = Color(0xFFFACC15);
}

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
  TimeOfDay? _selectedTime;

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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: SenRideColors.green,
              surface: SenRideColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: SenRideColors.green,
              surface: SenRideColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _publier() async {
    final depart = _departController.text.trim();
    final arrivee = _arriveeController.text.trim();
    final prix = int.tryParse(_prixController.text.trim());
    final places = int.tryParse(_placesController.text.trim());

    if (depart.isEmpty || arrivee.isEmpty || _selectedDate == null || _selectedTime == null || places == null || prix == null) {
      _showSnackBar('Veuillez remplir tous les champs correctement.');
      return;
    }

    final DateTime dateTimeVoyage = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );

    try {
      await FirebaseFirestore.instance.collection('trajets').add({
        'villeDepart': depart,
        'villeArrivee': arrivee,
        'dateHeureDepart': Timestamp.fromDate(dateTimeVoyage),
        'places': places,
        'prix': prix,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Trajet publié avec succès !');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SenRideColors.background, // Fond uniforme de l'accueil
      appBar: AppBar(
        title: const Text('Publier un trajet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: SenRideColors.card,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(controller: _departController, label: 'Ville de départ', icon: Icons.location_on, color: SenRideColors.aqua),
            const SizedBox(height: 16),
            _buildTextField(controller: _arriveeController, label: 'Ville d\'arrivée', icon: Icons.flag, color: SenRideColors.green),
            const SizedBox(height: 16),
            
            // Ligne Date et Heure
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: SenRideColors.field, borderRadius: BorderRadius.circular(14), border: Border.all(color: SenRideColors.border)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: SenRideColors.yellow, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedDate == null ? 'Date' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: SenRideColors.field, borderRadius: BorderRadius.circular(14), border: Border.all(color: SenRideColors.border)),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: SenRideColors.aqua, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedTime == null ? 'Heure' : _selectedTime!.format(context),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(controller: _placesController, label: 'Nombre de places (1-8)', icon: Icons.person, color: SenRideColors.yellow, isNumber: true),
            const SizedBox(height: 16),
            _buildTextField(controller: _prixController, label: 'Prix par place (FCFA)', icon: Icons.money, color: SenRideColors.green, isNumber: true),
            const SizedBox(height: 24),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SenRideColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _publier,
              child: const Text('Publier le trajet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, required Color color, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: color),
        filled: true,
        fillColor: SenRideColors.field,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}