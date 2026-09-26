import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SenRideColors {
  static const background = Color(0xFF071D24);
  static const card = Color(0xFF0E2A33);
  static const field = Color(0xFF10323D);
  static const border = Color(0x33FFFFFF);
  static const green = Color(0xFF16A34A);
  static const aqua = Color(0xFF38BDF8);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLogin = true; // Vrai si on se connecte, Faux si on s'inscrit
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // Connexion
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        _showSnackBar('Connexion réussie !');
      } else {
        // Inscription
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        _showSnackBar('Compte créé avec succès !');
      }
      // La navigation vers l'accueil/main se fera automatiquement si tu écoutes l'état d'auth, 
      // ou tu peux faire un Navigator.pop(context) si l'écran est appelé ponctuellement.
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Erreur : ${e.message}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SenRideColors.background,
      appBar: AppBar(
        title: Text(_isLogin ? 'Connexion SenRide' : 'Inscription SenRide',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: SenRideColors.card,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.directions_car, size: 80, color: SenRideColors.green),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: SenRideColors.aqua, fontSize: 12, fontWeight: FontWeight.bold),
                  prefixIcon: const Icon(Icons.email, color: SenRideColors.aqua),
                  filled: true,
                  fillColor: SenRideColors.field,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: const TextStyle(color: SenRideColors.green, fontSize: 12, fontWeight: FontWeight.bold),
                  prefixIcon: const Icon(Icons.lock, color: SenRideColors.green),
                  filled: true,
                  fillColor: SenRideColors.field,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: SenRideColors.green))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SenRideColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _submit,
                      child: Text(_isLogin ? 'Se connecter' : 'S\'inscrire',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Pas encore de compte ? S\'inscrire' : 'Déjà un compte ? Se connecter',
                  style: const TextStyle(color: SenRideColors.aqua),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}