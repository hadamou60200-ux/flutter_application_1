import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Contrôleurs pour les champs de texte
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _plaqueController = TextEditingController();

  bool _isConducteur = false;

  XFile? _idImage;
  XFile? _selfieImage;
  XFile? _permisImage; 
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _marqueController.dispose();
    _plaqueController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 'id') _idImage = pickedFile;
        if (type == 'selfie') _selfieImage = pickedFile;
        if (type == 'permis') _permisImage = pickedFile;
      });
    }
  }

  Future<void> _submitToFirebase() async {
    // Validation des champs obligatoires de base
    if (_prenomController.text.trim().isEmpty ||
        _nomController.text.trim().isEmpty ||
        _adresseController.text.trim().isEmpty ||
        _telephoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _idImage == null ||
        _selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et fournir les photos (ID et Selfie).')),
      );
      return;
    }

    // Si c'est un conducteur, on vérifie les champs spécifiques
    if (_isConducteur) {
      if (_marqueController.text.trim().isEmpty ||
          _plaqueController.text.trim().isEmpty ||
          _permisImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('En tant que conducteur, veuillez renseigner la marque, la plaque et la photo du permis.')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Création du compte Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2. Upload de la Pièce d'identité (Optimisé sans readAsBytes)
      TaskSnapshot idUploadTask = await FirebaseStorage.instance
          .ref()
          .child('kyc_images/$uid/id.jpg')
          .putFile(File(_idImage!.path));
      String idUrl = await idUploadTask.ref.getDownloadURL();

      // 3. Upload du Selfie (Optimisé)
      TaskSnapshot selfieUploadTask = await FirebaseStorage.instance
          .ref()
          .child('kyc_images/$uid/selfie.jpg')
          .putFile(File(_selfieImage!.path));
      String selfieUrl = await selfieUploadTask.ref.getDownloadURL();

      // 4. Upload du Permis (uniquement si conducteur)
      String? permisUrl;
      if (_isConducteur && _permisImage != null) {
        TaskSnapshot permisUploadTask = await FirebaseStorage.instance
            .ref()
            .child('kyc_images/$uid/permis.jpg')
            .putFile(File(_permisImage!.path));
        permisUrl = await permisUploadTask.ref.getDownloadURL();
      }

      // 5. Enregistrement des données complètes dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'prenom': _prenomController.text.trim(),
        'nom': _nomController.text.trim(),
        'email': _emailController.text.trim(),
        'adresse': _adresseController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        'isConducteur': _isConducteur,
        'statutConducteur': _isConducteur ? 'en_attente' : '', // Défini dans tous les cas
        'idCardUrl': idUrl,
        'selfieUrl': selfieUrl,
        'marqueVehicule': _isConducteur ? _marqueController.text.trim() : '',
        'plaqueImmatriculation': _isConducteur ? _plaqueController.text.trim() : '',
        'permisUrl': permisUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription validée avec succès !')),
      );

      // Redirection après succès
      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
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
        title: const Text('Inscription SenRide', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _prenomController,
                      decoration: const InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse au Sénégal', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Numéro de téléphone (ex: +221 ...)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Adresse e-mail', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              
              // Boutons pour les images KYC
              ElevatedButton.icon(
                onPressed: () => _pickImage('id'),
                icon: const Icon(Icons.credit_card),
                label: Text(_idImage == null ? 'Sélectionner la pièce d\'identité' : 'Pièce sélectionnée ✓'),
              ),
              if (_idImage != null) ...[
                const SizedBox(height: 10),
                Image.file(File(_idImage!.path), height: 100),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage('selfie'),
                icon: const Icon(Icons.camera_alt),
                label: Text(_selfieImage == null ? 'Sélectionner le selfie' : 'Selfie sélectionné ✓'),
              ),
              if (_selfieImage != null) ...[
                const SizedBox(height: 10),
                Image.file(File(_selfieImage!.path), height: 100),
              ],
              
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Je m\'inscris en tant que Conducteur', style: TextStyle(fontWeight: FontWeight.bold)),
                value: _isConducteur,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  setState(() {
                    _isConducteur = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              
              if (_isConducteur) ...[
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
                  onPressed: () => _pickImage('permis'),
                  icon: const Icon(Icons.card_travel),
                  label: Text(_permisImage == null ? 'Sélectionner le permis de conduire' : 'Permis sélectionné ✓'),
                ),
                if (_permisImage != null) ...[
                  const SizedBox(height: 10),
                  Image.file(File(_permisImage!.path), height: 100),
                ],
                const SizedBox(height: 20),
              ],
              
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _submitToFirebase,
                      child: const Text('Valider l\'inscription', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}