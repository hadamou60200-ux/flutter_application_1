import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BecomeDriverPage extends StatefulWidget {
  const BecomeDriverPage({super.key});

  @override
  State<BecomeDriverPage> createState() => _BecomeDriverPageState();
}

class _BecomeDriverPageState extends State<BecomeDriverPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _plaqueController = TextEditingController();
  
  XFile? _permisImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _marqueController.dispose();
    _plaqueController.dispose();
    super.dispose();
  }

  Future<void> _pickPermis() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _permisImage = pickedFile;
      });
    }
  }

  Future<void> _submitDriverInfo() async {
    if (_marqueController.text.trim().isEmpty ||
        _plaqueController.text.trim().isEmpty ||
        _permisImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et fournir la photo du permis.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String uid = user.uid;
      final tempDir = await Directory.systemTemp.createTemp();

      // 1. Upload de la photo du permis dans Firebase Storage
      final permisBytes = await _permisImage!.readAsBytes();
      final permisTempFile = File('${tempDir.path}/permis_$uid.jpg');
      await permisTempFile.writeAsBytes(permisBytes);
      
      TaskSnapshot permisUploadTask = await FirebaseStorage.instance
          .ref()
          .child('kyc_images/$uid/permis.jpg')
          .putFile(permisTempFile);
      String permisUrl = await permisUploadTask.ref.getDownloadURL();

      // 2. Mise à jour du document Firestore de l'utilisateur existant
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isConducteur': true,
        'marqueVehicule': _marqueController.text.trim(),
        'plaqueImmatriculation': _plaqueController.text.trim(),
        'permisUrl': permisUrl,
        'statutConducteur': 'en_attente', // En attente de validation par l'admin
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande envoyée ! En attente de validation par l\'administration.')),
      );

      Navigator.pop(context); // Retour à l'écran de profil
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devenir Conducteur SenRide'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Renseignez les informations de votre véhicule pour proposer des trajets.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _marqueController,
                decoration: const InputDecoration(labelText: 'Marque et modèle du véhicule', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _plaqueController,
                decoration: const InputDecoration(labelText: 'Plaque d\'immatriculation', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickPermis,
                icon: const Icon(Icons.card_travel),
                label: Text(_permisImage == null ? 'Sélectionner le permis de conduire' : 'Permis sélectionné ✓'),
              ),
              if (_permisImage != null) ...[
                const SizedBox(height: 10),
                Image.file(File(_permisImage!.path), height: 120),
              ],
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _submitDriverInfo,
                      child: const Text('Soumettre ma demande de conducteur', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}