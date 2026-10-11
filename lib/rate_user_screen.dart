import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RateUserScreen extends StatefulWidget {
  final String trajetId;
  final String destinataireId;
  final String destinataireNom;
  final bool isRatingDriver; // true si on note le conducteur, false si on note le passager

  const RateUserScreen({
    super.key,
    required this.trajetId,
    required this.destinataireId,
    required this.destinataireNom,
    required this.isRatingDriver,
  });

  @override
  State<RateUserScreen> createState() => _RateUserScreenState();
}

class _RateUserScreenState extends State<RateUserScreen> {
  static const Color background = Color(0xFF071D24);
  static const Color cardColor = Color(0xFF0E2A33);
  static const Color greenSenRide = Color(0xFF16A34A);

  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Enregistrer l'avis dans la collection 'avis'
      await FirebaseFirestore.instance.collection('avis').add({
        'trajetId': widget.trajetId,
        'auteurId': user.uid,
        'destinataireId': widget.destinataireId,
        'note': _rating,
        'commentaire': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Mettre à jour la note moyenne du profil utilisateur (optionnel mais propre)
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.destinataireId);
      final userDoc = await userDocRef.get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        double currentRating = (data['rating'] ?? 5.0).toDouble();
        int ratingCount = (data['ratingCount'] ?? 1).toInt();

        double newRating = ((currentRating * ratingCount) + _rating) / (ratingCount + 1);

        await userDocRef.update({
          'rating': double.parse(newRating.toStringAsFixed(1)),
          'ratingCount': ratingCount + 1,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avis envoyé avec succès ! Merci."), backgroundColor: greenSenRide),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          widget.isRatingDriver ? "Noter le conducteur" : "Noter le passager",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 35,
              backgroundColor: cardColor,
              child: Icon(Icons.person, size: 40, color: greenSenRide),
            ),
            const SizedBox(height: 16),
            Text(
              widget.destinataireNom,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isRatingDriver ? "Comment s'est passée votre route avec lui ?" : "Comment s'est comporté ce passager ?",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Étoiles de notation interactives
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                int starIndex = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starIndex),
                  icon: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Text(
              "$_rating / 5 étoiles",
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Champ de commentaire
            TextField(
              controller: _commentController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Laissez un commentaire (ex: Ponctuel, sympathique, conduite prudente...)",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Bouton de validation
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenSenRide,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Publier l'avis",
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