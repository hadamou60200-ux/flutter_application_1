import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const Color greenSenRide = Color(0xFF16A34A);
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// 1. Initialiser FCM (Demande de permission et sauvegarde du token)
  Future<void> initializeFCM() async {
    // Demander la permission (surtout pour iOS et Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Récupérer le token FCM de l'appareil
      String? token = await _fcm.getToken();
      if (token != null) {
        _saveTokenToDatabase(token);
      }

      // Écouter le rafraîchissement du token
      _fcm.onTokenRefresh.listen(_saveTokenToDatabase);
    }
  }

  /// Sauvegarder le token FCM dans le profil Firestore de l'utilisateur
  Future<void> _saveTokenToDatabase(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    } catch (_) {
      // Si le document n'existe pas encore ou autre erreur mineure
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }

  /// 2. Écouter les changements de réservation en temps réel (In-App)
  void listenToReservationUpdates(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('reservations')
        .where('passengerId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;
          final status = data['status'];
          final departure = data['departureCity'] ?? '';
          final arrival = data['arrivalCity'] ?? '';

          if (status == 'accepted') {
            _showInAppNotification(
              context,
              title: "Réservation Acceptée ! 🎉",
              message: "Votre trajet $departure ➔ $arrival a été validé par le conducteur.",
              isSuccess: true,
            );
          } else if (status == 'rejected') {
            _showInAppNotification(
              context,
              title: "Réservation Refusée ❌",
              message: "Le conducteur ne peut pas vous prendre sur le trajet $departure ➔ $arrival.",
              isSuccess: false,
            );
          }
        }
      }
    });
  }

  /// 3. Afficher un banner In-App fluide et élégant
  void _showInAppNotification(
    BuildContext context, {
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFF0E2A33),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(
          isSuccess ? Icons.check_circle : Icons.cancel,
          color: isSuccess ? greenSenRide : Colors.redAccent,
          size: 32,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('OK', style: TextStyle(color: greenSenRide, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}