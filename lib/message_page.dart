import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static const Color greenSenRide = Color(0xFF16A34A);

  Future<void> _ouvrirWhatsApp(BuildContext context, String numero) async {
    final Uri url = Uri.parse("https://wa.me/$numero");
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ouverture')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          final name = item['name'] ?? '?';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: greenSenRide.withValues(alpha: 0.2),
                  child: Text(
                    name.isNotEmpty ? name[0] : '?', // CORRECTION : pas de crash si vide
                    style: const TextStyle(
                        color: greenSenRide, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  item['message'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                  onPressed: () => _ouvrirWhatsApp(context, item['phone'] ?? ''),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
