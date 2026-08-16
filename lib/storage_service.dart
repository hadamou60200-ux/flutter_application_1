// lib/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadMyFile(File fileLocal) async {
    final storageRef = _storage.ref().child("profiles/user_1.png");
    try {
      await storageRef.putFile(fileLocal);
      print("Fichier téléversé !");
    } catch (e) {
      print("Erreur : $e");
    }
  }
}
