import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'resultats_screen.dart';
import 'publish_trip_screen.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  // Contrôleur pour gérer et modifier le texte du champ "Départ"
  final TextEditingController _departController = TextEditingController();
  bool _isLoadingLocation = false;

  // Fonction pour récupérer la position actuelle (latitude, longitude)
  Future<void> _determineCurrentCity() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Les services de localisation sont désactivés.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Permissions de localisation refusées.');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Permissions refusées définitivement dans les paramètres.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // On inscrit directement les coordonnées GPS ou une valeur par défaut propre
      setState(() {
        _departController.text = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      });
      
      _showSnackBar('Position récupérée avec succès !');

    } catch (e) {
      _showSnackBar('Erreur lors de la géolocalisation : $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _departController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16A34A),
        elevation: 0,
        title: const Text(
          'Accueil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications, color: Colors.white, size: 28),
                Positioned(
                  top: 10,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salutation
            const Text(
              'Bonjour 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            const Text(
              'Où allez-vous aujourd\'hui ?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Choix du rôle : Chercher ou Proposer
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ResultatsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.search, color: Colors.white, size: 20),
                    label: const Text(
                      'Chercher',
                      style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PublishTripScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                    label: const Text(
                      'Proposer',
                      style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Carte de recherche principale avec Départ et Arrivée
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Champ Départ avec bouton de géolocalisation intégré
                  TextField(
                    controller: _departController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF16A34A)),
                      suffixIcon: _isLoadingLocation
                          ? Transform.scale(
                              scale: 0.5,
                              child: const CircularProgressIndicator(strokeWidth: 3),
                            )
                          : IconButton(
                              icon: const Icon(Icons.my_location, color: Color(0xFF16A34A)),
                              tooltip: 'Utiliser ma position actuelle',
                              onPressed: _determineCurrentCity,
                            ),
                      hintText: 'Départ (ex: Dakar)',
                      hintStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      filled: true,
                      fillColor: const Color(0xFFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Champ Arrivée
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.flag, color: Colors.blueAccent),
                      hintText: 'Arrivée (ex: Thiès, Saint-Louis...)',
                      hintStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      filled: true,
                      fillColor: const Color(0xFFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Date et Passagers
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('24 Mai 2024', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.person, size: 18, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('2 passagers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bouton Rechercher un trajet détaillé
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ResultatsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text(
                        'Rechercher un trajet',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bannière publicitaire
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voyagez ensemble, économisez davantage !',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Trouvez des conducteurs vérifiés près de chez vous.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.directions_car, size: 50, color: Color(0xFF16A34A)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Petits boutons d'accès rapide du bas
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _QuickFeatureItem(icon: Icons.security, label: 'Trajets sûrs'),
                _QuickFeatureItem(icon: Icons.payment, label: 'Paiements'),
                _QuickFeatureItem(icon: Icons.verified_user, label: 'Confiance'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget utilitaire pour les icônes du bas
class _QuickFeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickFeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF16A34A), size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }
}