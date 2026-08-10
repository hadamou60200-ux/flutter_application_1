import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({Key? key}) : super(key: key);

  // Fonction pour mettre à jour le statut (Approuvé ou Rejeté)
  Future<void> _updateStatus(String userId, String status) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'status': status, // ex: 'approved' ou 'rejected'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration - KYC SenRide'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // On écoute la collection 'users' que l'on vient de créer
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune demande KYC en attente.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final userId = docs[index].id;
              final adresse = data['adresse'] ?? 'Adresse non spécifiée';
              final idCardUrl = data['idCardUrl'] ?? '';
              final selfieUrl = data['selfieUrl'] ?? '';
              final status = data['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Adresse : $adresse', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text('Statut actuel : $status', style: TextStyle(color: status == 'approved' ? Colors.green : Colors.orange)),
                      const SizedBox(height: 10),
                      
                      // Affichage des images miniatures depuis les liens Firebase Storage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          idCardUrl.isNotEmpty 
                              ? Image.network(idCardUrl, height: 80, width: 80, fit: BoxFit.cover)
                              : const Text('Pas de Pièce ID'),
                          selfieUrl.isNotEmpty 
                              ? Image.network(selfieUrl, height: 80, width: 80, fit: BoxFit.cover)
                              : const Text('Pas de Selfie'),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Boutons d'action Valider / Rejeter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => _updateStatus(userId, 'approved'),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Approuver', style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => _updateStatus(userId, 'rejected'),
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: const Text('Rejeter', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}