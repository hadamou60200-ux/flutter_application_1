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
  
  // Contrôleurs pour les champs de texte
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Ajouté pour l'e-mail
  final TextEditingController _passwordController = TextEditingController(); // Ajouté pour le mot de passe
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _plaqueController = TextEditingController();

  bool _isConducteur = false;

  XFile? _idImage;
  XFile? _selfieImage;
  XFile? _permisImage; // Image du permis pour les conducteurs
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

  // Sélectionner la pièce d'identité
  Future<void> _pickIdImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _idImage = pickedFile;
      });
    }
  }

  // Sélectionner le selfie
  Future<void> _pickSelfieImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selfieImage = pickedFile;
      });
    }
  }

  // Sélectionner le permis de conduire
  Future<void> _pickPermisImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _permisImage = pickedFile;
      });
    }
  }

  // Fonction d'envoi sécurisée vers Firebase Storage et Firestore
  Future<void> _submitToFirebase() async {
    // Validation des champs obligatoires de base
    if (_prenomController.text.isEmpty ||
        _nomController.text.isEmpty ||
        _adresseController.text.isEmpty ||
        _telephoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _idImage == null ||
        _selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires (dont e-mail et mot de passe) et fournir les photos.')),
      );
      return;
    }

    // Si c'est un conducteur, on vérifie les champs spécifiques
    if (_isConducteur) {
      if (_marqueController.text.isEmpty ||
          _plaqueController.text.isEmpty ||
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
      print("DEBUG: Création du compte Firebase Auth...");
      // 1. Création du compte avec l'e-mail et le mot de passe
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      print("DEBUG: Début de la préparation des images...");
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final tempDir = await Directory.systemTemp.createTemp();

      // Pièce d'identité
      final idBytes = await _idImage!.readAsBytes();
      final idTempFile = File('${tempDir.path}/id_$timestamp.jpg');
      await idTempFile.writeAsBytes(idBytes);

      // Selfie
      final selfieBytes = await _selfieImage!.readAsBytes();
      final selfieTempFile = File('${tempDir.path}/selfie_$timestamp.jpg');
      await selfieTempFile.writeAsBytes(selfieBytes);

      // Permis (si conducteur)
      File? permisTempFile;
      if (_isConducteur && _permisImage != null) {
        final permisBytes = await _permisImage!.readAsBytes();
        permisTempFile = File('${tempDir.path}/permis_$timestamp.jpg');
        await permisTempFile.writeAsBytes(permisBytes);
      }

      print("DEBUG: Début de l'envoi vers Firebase Storage...");

      // Upload ID
      TaskSnapshot idUploadTask = await FirebaseStorage.instance
          .ref()
          .child('kyc_images/$uid/id.jpg')
          .putFile(idTempFile);
      String idUrl = await idUploadTask.ref.getDownloadURL();

      // Upload Selfie
      TaskSnapshot selfieUploadTask = await FirebaseStorage.instance
          .ref()
          .child('kyc_images/$uid/selfie.jpg')
          .putFile(selfieTempFile);
      String selfieUrl = await selfieUploadTask.ref.getDownloadURL();

      // Upload Permis (si conducteur)
      String? permisUrl;
      if (_isConducteur && permisTempFile != null) {
        TaskSnapshot permisUploadTask = await FirebaseStorage.instance
            .ref()
            .child('kyc_images/$uid/permis.jpg')
            .putFile(permisTempFile);
        permisUrl = await permisUploadTask.ref.getDownloadURL();
      }

      print("DEBUG: Images uploadées avec succès !");

      // Enregistrement des données dans Firestore (on utilise l'UID comme ID de document)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'prenom': _prenomController.text.trim(),
        'nom': _nomController.text.trim(),
        'email': _emailController.text.trim(),
        'adresse': _adresseController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        'isConducteur': _isConducteur,
        'idCardUrl': idUrl,
        'selfieUrl': selfieUrl,
        if (_isConducteur) ...{
          'marqueVehicule': _marqueController.text.trim(),
          'plaqueImmatriculation': _plaqueController.text.trim(),
          'permisUrl': permisUrl,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription validée avec succès !')),
      );

      Navigator.pop(context, true);

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
        title: const Text('Inscription SenRide'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Prénom et Nom
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _prenomController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Adresse
              TextField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse au Sénégal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Numéro de téléphone
              TextField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone (ex: +221 ...)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Adresse e-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Mot de passe
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Pièce d'identité
              ElevatedButton.icon(
                onPressed: _pickIdImage,
                icon: const Icon(Icons.credit_card),
                label: Text(_idImage == null ? 'Sélectionner la pièce d\'identité' : 'Pièce sélectionnée ✓'),
              ),
              if (_idImage != null) ...[
                const SizedBox(height: 10),
                Image.file(File(_idImage!.path), height: 100),
              ],
              const SizedBox(height: 20),

              // Selfie
              ElevatedButton.icon(
                onPressed: _pickSelfieImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(_selfieImage == null ? 'Sélectionner le selfie' : 'Selfie sélectionné ✓'),
              ),
              if (_selfieImage != null) ...[
                const SizedBox(height: 10),
                Image.file(File(_selfieImage!.path), height: 100),
              ],
              const SizedBox(height: 20),

              // Case à cocher / Switch pour Conducteur
              SwitchListTile(
                title: const Text('Je m\'inscris en tant que Conducteur'),
                value: _isConducteur,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  setState(() {
                    _isConducteur = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Champs spécifiques au conducteur (si activé)
              if (_isConducteur) ...[
                TextField(
                  controller: _marqueController,
                  decoration: const InputDecoration(
                    labelText: 'Marque et modèle du véhicule',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _plaqueController,
                  decoration: const InputDecoration(
                    labelText: 'Plaque d\'immatriculation',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickPermisImage,
                  icon: const Icon(Icons.card_travel),
                  label: Text(_permisImage == null ? 'Sélectionner le permis de conduire' : 'Permis sélectionné ✓'),
                ),
                if (_permisImage != null) ...[
                  const SizedBox(height: 10),
                  Image.file(File(_permisImage!.path), height: 100),
                ],
                const SizedBox(height: 20),
              ],

              // Bouton de validation
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