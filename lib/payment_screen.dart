import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final String trajetId;
  final String reservationId;
  final double amount; // Montant en FCFA
  final String driverName;

  const PaymentScreen({
    super.key,
    required this.trajetId,
    required this.reservationId,
    required this.amount,
    required this.driverName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color background = Color(0xFF071D24);
  static const Color cardColor = Color(0xFF0E2A33);
  static const Color greenSenRide = Color(0xFF16A34A);

  // Couleurs spécifiques aux opérateurs
  static const Color waveColor = Color(0xFF11B1E5); // Bleu Wave
  static const Color orangeColor = Color(0xFFFF6600); // Orange Money

  String _selectedMethod = 'wave'; // 'wave' ou 'orange'
  bool _isProcessing = false;

  // Lancement du paiement officiel via le backend Firebase Functions
  Future<void> _processOfficialPayment() async {
    setState(() => _isProcessing = true);

    try {
      // Appel de la Cloud Function sécurisée qui interagit avec les APIs Wave / Orange Money officielles
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createOfficialPayment');
      
      final response = await callable.call({
        'reservationId': widget.reservationId,
        'amount': widget.amount,
        'currency': 'XOF',
        'provider': _selectedMethod, // 'wave' ou 'orange'
      });

      final data = response.data as Map<String, dynamic>;
      final String? paymentUrl = data['paymentUrl'];

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        final Uri uri = Uri.parse(paymentUrl);
        if (await canLaunchUrl(uri)) {
          // Ouvre la page de paiement officielle sécurisée (Wave Web Checkout ou Orange Web Payment)
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Redirection vers la plateforme de paiement officielle..."),
          backgroundColor: greenSenRide,
        ),
      );

      Navigator.pop(context, true); // Indique le succès de l'initialisation
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de paiement officiel : $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Paiement Officiel SenRide", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Résumé du montant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: Column(
                children: [
                  const Text("Montant officiel à régler", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    "${widget.amount.toStringAsFixed(0)} FCFA",
                    style: const TextStyle(color: Color(0xFFFACC15), fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0x22FFFFFF)),
                  const SizedBox(height: 8),
                  Text("Conducteur : ${widget.driverName}", style: const TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Sélectionnez l'opérateur officiel",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Option WAVE Officiel
            GestureDetector(
              onTap: () => setState(() => _selectedMethod = 'wave'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedMethod == 'wave' ? waveColor : const Color(0x33FFFFFF),
                    width: _selectedMethod == 'wave' ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: waveColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.waves, color: waveColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Wave (Officiel)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 2),
                          Text("Redirection sécurisée Wave Checkout", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: 'wave',
                      groupValue: _selectedMethod,
                      activeColor: waveColor,
                      onChanged: (val) => setState(() => _selectedMethod = val!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Option ORANGE MONEY Officiel
            GestureDetector(
              onTap: () => setState(() => _selectedMethod = 'orange'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedMethod == 'orange' ? orangeColor : const Color(0x33FFFFFF),
                    width: _selectedMethod == 'orange' ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: orangeColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_android, color: orangeColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Orange Money (Officiel)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 2),
                          Text("API Web Payment Sonatel", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: 'orange',
                      groupValue: _selectedMethod,
                      activeColor: orangeColor,
                      onChanged: (val) => setState(() => _selectedMethod = val!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Bouton de validation officiel
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processOfficialPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenSenRide,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        "Procéder au paiement officiel",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}