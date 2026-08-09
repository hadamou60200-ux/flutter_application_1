import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  // Fonction pour ouvrir WhatsApp avec un numéro de téléphone
  Future<void> _ouvrirWhatsApp(String numero) async {
    final Uri url = Uri.parse("https://wa.me/$numero");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d\'ouvrir WhatsApp pour $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color greenSenRide = Color(0xFF4CAF50);

    // Liste fictive de messages avec les numéros WhatsApp
    final List<Map<String, String>> messages = [
      {
        'name': 'Mamadou Diallo',
        'message': 'Bonjour, je serai au point de rdv dans 5 minutes.',
        'time': '10:30',
        'phone': '221770000000',
      },
      {
        'name': 'Aissatou Ba',
        'message': 'Merci pour le trajet ! C\'était super.',
        'time': 'Hier',
        'phone': '221780000000',
      },
      {
        'name': 'Cheikh Ndiaye',
        'message': 'Est-ce que vous acceptez les colis ?',
        'time': '04/08',
        'phone': '221760000000',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(color: Colors.white)),
        backgroundColor: greenSenRide,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final item = messages[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: greenSenRide.withValues(alpha: 0.2),
                  child: Text(
                    item['name']![0],
                    style: const TextStyle(color: greenSenRide, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  item['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item['message']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Icône WhatsApp interactive à droite
                trailing: IconButton(
                  icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                  onPressed: () {
                    _ouvrirWhatsApp(item['phone']!);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}