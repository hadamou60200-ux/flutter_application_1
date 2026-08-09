import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Fonction pour sélectionner une image (Galerie ou Caméra)
  Future<void> _pickImage(bool isIdCard) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isIdCard) {
          _idImage = image;
        } else {
          _selfieImage = image;
        }
      });
    }
  }

  // Fonction principale d'envoi vers Firebase avec gestion des erreurs
  Future<void> _submitToFirebase() async {
    // 1. Vérification des champs et des images
    if (_adresseController.text.isEmpty || _idImage == null || _selfieImage == null) {
      print("DEBUG: Blocage -> Adresse vide: ${_adresseController.text.isEmpty}, Image ID nulle: ${_idImage == null}, Selfie nul: ${_selfieImage == null}");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir l\'adresse et sélectionner les deux images')),
      );
      return; 
    }

    // 2. Activation du chargement
    setState(() {
      _isLoading = true;
    });

    try {
      print("DEBUG: Début de l'envoi vers Firebase Storage...");

      // Nom unique basé sur le temps actuel
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload de la carte d'identité
      Reference idRef = FirebaseStorage.instance.ref().child('kyc_images/id_$timestamp.jpg');
      await idRef.putFile(File(_idImage!.path));
      String idUrl = await idRef.getDownloadURL();

      // Upload du selfie
      Reference selfieRef = FirebaseStorage.instance.ref().child('kyc_images/selfie_$timestamp.jpg');
      await selfieRef.putFile(File(_selfieImage!.path));
      String selfieUrl = await selfieRef.getDownloadURL();

      print("DEBUG: Images uploadées avec succès. Enregistrement Firestore...");

      // Enregistrement des métadonnées dans Cloud Firestore
      await FirebaseFirestore.instance.collection('users_kyc').add({
        'adresse': _adresseController.text.trim(),
        'idCardUrl': idUrl,
        'selfieUrl': selfieUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("DEBUG: Inscription et KYC validés avec succès !");
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription validée avec succès !')),
      );

      // Réinitialisation du formulaire après succès
      _adresseController.clear();
      setState(() {
        _idImage = null;
        _selfieImage = null;
      });

    } catch (e) {
      print("DEBUG ERREUR FIREBASE: $e");
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      // Désactive l'indicateur de chargement
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription KYC SenRide'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Champ Adresse
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse au Sénégal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Bouton sélection Pièce d'identité
              ElevatedButton.icon(
                onPressed: () => _pickImage(true),
                icon: const Icon(Icons.credit_card),
                label: Text(_idImage == null ? 'Sélectionner la Pièce d\'identité' : 'Pièce sélectionnée ✓'),
              ),
              if (_idImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(File(_idImage!.path), height: 100),
                ),
              const SizedBox(height: 20),

              // Bouton sélection Selfie
              ElevatedButton.icon(
                onPressed: () => _pickImage(false),
                icon: const Icon(Icons.camera_alt),
                label: Text(_selfieImage == null ? 'Sélectionner le Selfie' : 'Selfie sélectionné ✓'),
              ),
              if (_selfieImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(File(_selfieImage!.path), height: 100),
                ),
              const SizedBox(height: 30),

              // Bouton de validation final
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _submitToFirebase,
                      child: const Text(
                        'Valider l\'inscription',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}