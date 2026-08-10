import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminApprovalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Validation KYC")),
      body: StreamBuilder<QuerySnapshot>(
        // On récupère uniquement les comptes en attente
        stream: FirebaseFirestore.instance.collection('users').where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text("Utilisateur: ${docs[index].id}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () => _updateStatus(docs[index].id, 'approved'),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => _updateStatus(docs[index].id, 'rejected'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Fonction pour mettre à jour Firestore
  void _updateStatus(String userId, String newStatus) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'status': newStatus,
    });
  }
}