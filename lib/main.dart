import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <--- Import FCM
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- Import Firestore pour sauvegarder le token
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'main_navigation.dart';
import 'login_screen.dart';

// Fonction d'initialisation et de gestion des notifications FCM
Future<void> initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 1. Demander la permission (requis pour iOS et Android 13+)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Notifications autorisées par l\'utilisateur');
  }

  // 2. Récupérer le token FCM de l'appareil
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // 3. Sauvegarder automatiquement le token si un utilisateur est déjà connecté
  if (token != null) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }

  // 4. Écouter le rafraîchissement du token au cas où il change
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': newToken,
      }, SetOptions(merge: true));
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialisation de FCM au démarrage
  await initFCM();

  runApp(const SenRideApp());
}

class SenRideApp extends StatelessWidget {
  const SenRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF071D24),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF16A34A),
          surface: Color(0xFF0E2A33),
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF16A34A)),
              ),
            );
          }

          if (snapshot.hasData) {
            // Dès que l'utilisateur se connecte, on s'assure aussi de mettre à jour son token FCM
            FirebaseMessaging.instance.getToken().then((token) {
              if (token != null && snapshot.data != null) {
                FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).set({
                  'fcmToken': token,
                }, SetOptions(merge: true));
              }
            });
            return const MainNavigation();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}