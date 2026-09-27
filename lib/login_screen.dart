import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart'; // Importation de ta page d'inscription complète

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
  // Contrôleurs E-mail / Mot de passe
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Contrôleurs Téléphone / Code SMS
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();

  bool _isPhoneLogin = false; // false = Email, true = Téléphone
  bool _isLoading = false;
  bool _codeSent = false;
  String _verificationId = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 1. Connexion par E-mail
  Future<void> _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _showSnackBar('Connexion réussie !');
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Erreur : ${e.message}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2A. Étape Téléphone : Envoi du code SMS
  Future<void> _verifyPhoneNumber() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || !phone.startsWith('+')) {
      _showSnackBar('Veuillez entrer un numéro valide avec l\'indicatif (ex: +221...)');
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (!mounted) return;
        _showSnackBar('Connexion automatique réussie !');
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        _showSnackBar('Échec de la vérification : ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _isLoading = false;
        });
        _showSnackBar('Code SMS envoyé avec succès.');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // 2B. Étape Téléphone : Validation du code SMS
  Future<void> _signInWithSMSCode() async {
    final smsCode = _smsCodeController.text.trim();

    if (smsCode.length != 6) {
      _showSnackBar('Veuillez entrer un code à 6 chiffres valide.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      _showSnackBar('Connexion réussie !');
    } catch (e) {
      _showSnackBar('Code SMS incorrect : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SenRideColors.background,
      appBar: AppBar(
        title: const Text('Connexion SenRide',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

              // Sélecteur de mode de connexion (Email vs Téléphone)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Par E-mail'),
                    selected: !_isPhoneLogin,
                    selectedColor: SenRideColors.green,
                    backgroundColor: SenRideColors.card,
                    labelStyle: TextStyle(
                      color: !_isPhoneLogin ? Colors.white : SenRideColors.aqua,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _isPhoneLogin = false;
                        _codeSent = false;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Par Téléphone'),
                    selected: _isPhoneLogin,
                    selectedColor: SenRideColors.green,
                    backgroundColor: SenRideColors.card,
                    labelStyle: TextStyle(
                      color: _isPhoneLogin ? Colors.white : SenRideColors.aqua,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _isPhoneLogin = true;
                        _codeSent = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FORMULAIRE E-MAIL / MOT DE PASSE
              if (!_isPhoneLogin) ...[
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
                        onPressed: _loginWithEmail,
                        child: const Text('Se connecter',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ],

              // FORMULAIRE NUMÉRO DE TÉLÉPHONE
              if (_isPhoneLogin) ...[
                if (!_codeSent) ...[
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone (ex: +221...)',
                      labelStyle: const TextStyle(color: SenRideColors.aqua, fontSize: 12, fontWeight: FontWeight.bold),
                      prefixIcon: const Icon(Icons.phone, color: SenRideColors.aqua),
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
                          onPressed: _verifyPhoneNumber,
                          child: const Text('Recevoir le code SMS',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                ] else ...[
                  Text(
                    'Entrez le code à 6 chiffres envoyé au ${_phoneController.text}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _smsCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Code de vérification SMS',
                      labelStyle: const TextStyle(color: SenRideColors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      prefixIcon: const Icon(Icons.sms, color: SenRideColors.green),
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
                          onPressed: _signInWithSMSCode,
                          child: const Text('Valider et se connecter',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                  TextButton(
                    onPressed: () => setState(() => _codeSent = false),
                    child: const Text(
                      'Modifier le numéro de téléphone',
                      style: TextStyle(color: SenRideColors.aqua),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'Pas encore de compte ? S\'inscrire',
                  style: TextStyle(color: SenRideColors.aqua),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}