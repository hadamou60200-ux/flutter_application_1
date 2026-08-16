import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/main_navigation.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const SenRideApp());
}

class SenRideApp extends StatelessWidget {
  const SenRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}