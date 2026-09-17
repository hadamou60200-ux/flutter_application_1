import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart'; // généré par flutterfire configure
import 'main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SenRideApp());
}

class SenRideApp extends StatelessWidget {
  const SenRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenRide',
      debugShowCheckedModeBanner: false,
      // Thème global sombre et uniforme pour toute l'application
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF071D24), // Fond bleu nuit de l'accueil
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF16A34A), // Vert SenRide
          surface: Color(0xFF0E2A33), // Couleur de fond des cartes / dialogues
        ),
        useMaterial3: true,
      ),
      // Localisations pour le français (DatePicker, etc.)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'), // Français
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
      home: const MainNavigation(),
    );
  }
}