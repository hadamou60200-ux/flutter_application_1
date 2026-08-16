import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adresseController = TextEditingController();

  XFile? _idImage;
  XFile? _selfieImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // Sélectionner la pièce d'identité depuis la galerie
  Future<void> _pickIdImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _idImage = pickedFile;
      });
    }
  }

  // Sélectionner le selfie depuis la galerie (pour l'émulateur)
  Future<void> _pickSelfieImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selfieImage = pickedFile;
      });
    }
  }

  // Fonction d'envoi sécurisée vers Firebase Storage et Firestore
  Future<void> _submitToFirebase() async {
    if (_adresseController.text.isEmpty || _idImage == null || _selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir l\'adresse et sélectionner les deux images.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print("DEBUG: Début de la préparation des images...");
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // 1. Conversion sécurisée de l'image ID en fichier temporaire local valide
      final idBytes = await _idImage!.readAsBytes();
      final tempDir = await Directory.systemTemp.createTemp();
      final idTempFile = File('${tempDir.path}/id_$timestamp.jpg');
      await idTempFile.writeAsBytes(idBytes);

      // 2. Conversion sécurisée du selfie en fichier temporaire local valide
      final selfieBytes = await _selfieImage!.readAsBytes();
      final selfieTempFile = File('${tempDir.path}/selfie_$timestamp.jpg');
      await selfieTempFile.writeAsBytes(selfieBytes);

      print("DEBUG: Début de l'envoi vers Firebase Storage...");

      // Upload de la carte d'identité
      TaskSnapshot idUploadTask = await FirebaseStorage.instance
          .ref()
          .child('kyc_images/id_$timestamp.jpg')
          .putFile(idTempFile);
      String idUrl = await idUploadTask.ref.getDownloadURL();

      // Upload du selfie
      TaskSnapshot selfieUploadTask = await FirebaseStorage.instance
          .ref()
          .child('kyc_images/selfie_$timestamp.jpg')
          .putFile(selfieTempFile);
      String selfieUrl = await selfieUploadTask.ref.getDownloadURL();

      print("DEBUG: Images uploadées avec succès !");

      // Enregistrement des données dans Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'adresse': _adresseController.text,
        'idCardUrl': idUrl,
        'selfieUrl': selfieUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await FirebaseAuth.instance.signInAnonymously();
      ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Inscription validée avec succès !')),
);
if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigation(),
        ),
      );
      await FirebaseAuth.instance.signInAnonymously();
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Inscription validée avec succès !')),
);

if (mounted) {
  // On renvoie 'true' à la page d'accueil pour cacher le bouton et on ferme la page d'inscription
  Navigator.pop(context, true);
}
    }

    } catch (e) {
      print("DEBUG ERREUR FIREBASE : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription KYC SenRide'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse au Sénégal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickIdImage,
                icon: const Icon(Icons.credit_card),
                label: Text(_idImage == null ? 'Sélectionner la pièce' : 'Pièce sélectionnée ✓'),
              ),
              const SizedBox(height: 10),
              if (_idImage != null)
                Image.file(File(_idImage!.path), height: 100),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickSelfieImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(_selfieImage == null ? 'Sélectionner le selfie' : 'Selfie sélectionné ✓'),
              ),
              const SizedBox(height: 10),
              if (_selfieImage != null)
                Image.file(File(_selfieImage!.path), height: 100),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _submitToFirebase,
                      child: const Text('Valider l\'inscription', style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}