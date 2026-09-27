import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleManagementPage extends StatefulWidget {
  const VehicleManagementPage({super.key});

  @override
  State<VehicleManagementPage> createState() => _VehicleManagementPageState();
}

class _VehicleManagementPageState extends State<VehicleManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _plaqueController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  Future<void> _loadVehicleData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
          _marqueController.text = data['marqueVehicule'] ?? '';
          _plaqueController.text = data['plaqueImmatriculation'] ?? '';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement : $e')),
      );
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _updateVehicleInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'marqueVehicule': _marqueController.text.trim(),
        'plaqueImmatriculation': _plaqueController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations du véhicule mises à jour avec succès !')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _marqueController.dispose();
    _plaqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon véhicule & Permis', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF16A34A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Icon(Icons.directions_car, size: 70, color: Color(0xFF16A34A)),
                    const SizedBox(height: 16),
                    const Text(
                      'Modifiez les informations de votre véhicule ci-dessous.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _marqueController,
                      decoration: const InputDecoration(
                        labelText: 'Marque et modèle du véhicule',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.car_repair),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer la marque' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _plaqueController,
                      decoration: const InputDecoration(
                        labelText: 'Plaque d\'immatriculation',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer la plaque' : null,
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)))
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _updateVehicleInfo,
                            child: const Text('Enregistrer les modifications',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}