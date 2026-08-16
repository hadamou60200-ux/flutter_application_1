import 'package:flutter/material.dart';

class ResultatsScreen extends StatelessWidget {
  const ResultatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16A34A),
        title: const Text(
          'Résultats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Barre de filtre haut (Trajet Dakar -> Thiès)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Chip(
                  label: const Text('Tous'),
                  backgroundColor: const Color(0xFF16A34A),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Dakar ➔ Thiès',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Liste des trajets disponibles
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _TrajetCard(
                  nom: 'Mamadou D.',
                  note: '4.8 (125)',
                  trajet: 'Dakar ➔ Thiès',
                  voiture: 'Toyota RAV4',
                  places: '3 places restantes',
                  prix: '2 500 FCFA',
                ),
                SizedBox(height: 12),
                _TrajetCard(
                  nom: 'Fatou Ndoye',
                  note: '4.6 (98)',
                  trajet: 'Dakar ➔ Thiès',
                  voiture: 'Hyundai Tucson',
                  places: '2 places restantes',
                  prix: '2 500 FCFA',
                ),
                SizedBox(height: 12),
                _TrajetCard(
                  nom: 'Ibrahima S.',
                  note: '4.9 (210)',
                  trajet: 'Dakar ➔ Thiès',
                  voiture: 'Peugeot 3008',
                  places: '4 places restantes',
                  prix: '2 500 FCFA',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour une carte de trajet individuelle
class _TrajetCard extends StatelessWidget {
  final String nom;
  final String note;
  final String trajet;
  final String voiture;
  final String places;
  final String prix;

  const _TrajetCard({
    required this.nom,
    required this.note,
    required this.trajet,
    required this.voiture,
    required this.places,
    required this.prix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(note, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trajet, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('$voiture • $places', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(prix, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF16A34A))),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Réserver', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}