import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'resultats_screen.dart';
import 'publish_trip_screen.dart';

/// Couleurs du thème SenRide "Aquatic Immersion".
class SenRideColors {
  SenRideColors._();

  static const background = Color(0xFF071D24); // bleu nuit profond
  static const card = Color(0xFF0E2A33); // carte glassmorphism
  static const field = Color(0xFF10323D); // champs de saisie
  static const border = Color(0x33FFFFFF); // contours discrets
  static const green = Color(0xFF16A34A); // vert SenRide
  static const aqua = Color(0xFF38BDF8); // bleu aquatique
  static const yellow = Color(0xFFFACC15); // jaune drapeau
  static const flagGreen = Color(0xFF00853F);
  static const flagRed = Color(0xFFE31B23);
}

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _arriveeController = TextEditingController();
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    super.dispose();
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _determineCurrentCity() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _message('Les services de localisation sont désactivés.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _message('Permissions de localisation refusées.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _message('Permissions refusées définitivement dans les paramètres.');
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _departController.text =
            "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      });
      _message('Position récupérée avec succès !');
    } catch (e) {
      _message('Erreur lors de la géolocalisation : $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _rechercher() {
    if (_departController.text.trim().isEmpty ||
        _arriveeController.text.trim().isEmpty) {
      _message('Veuillez renseigner le départ et l\'arrivée.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultatsScreen(
          villeDepart: _departController.text.trim(),
          villeArrivee: _arriveeController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SenRideColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: _SearchPanel(
                    departController: _departController,
                    arriveeController: _arriveeController,
                    loadingLocation: _isLoadingLocation,
                    onLocation: _determineCurrentCity,
                    onSearch: _rechercher,
                    onPublish: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PublishTripScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const _SectionTitle(title: 'Trajets populaires'),
                const SizedBox(height: 12),
                _PopularRidesPlaceholder(onSearch: _rechercher),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 248,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo de la Corniche de Dakar (déclare assets/dakar-corniche.jpg dans pubspec.yaml)
          Image.asset('assets/dakar-corniche.jpg', fit: BoxFit.cover),
          // Voile dégradé pour la lisibilité
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x5C071D24),
                  SenRideColors.background,
                ],
                stops: [0.05, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: SenRideColors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.directions_car_filled,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SenRide',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            SizedBox(height: 3),
                            Row(children: [
                              SenegalFlag(),
                              SizedBox(width: 7),
                              Text('COVOITURAGE SÉNÉGAL',
                                  style: TextStyle(
                                      color: Color(0xCCFFFFFF),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2)),
                            ]),
                          ],
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0x66071920),
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                              BorderSide(color: Color(0x33FFFFFF))),
                        ),
                        child: IconButton(
                          tooltip: 'Notifications',
                          onPressed: () => _message('Aucune nouvelle notification.'),
                          icon: const Icon(Icons.notifications_none,
                              color: Colors.white, size: 21),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text('BONSOIR',
                      style: TextStyle(
                          color: SenRideColors.yellow,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4)),
                  const SizedBox(height: 5),
                  const Text.rich(
                    TextSpan(children: [
                      TextSpan(text: 'Où partez-vous\n'),
                      TextSpan(
                          text: 'ce soir ?',
                          style: TextStyle(color: SenRideColors.aqua)),
                    ]),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.03,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Drapeau du Sénégal (vert / jaune-étoile / rouge).
class SenegalFlag extends StatelessWidget {
  const SenegalFlag({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 29,
        height: 18,
        child: Row(children: [
          const Expanded(child: ColoredBox(color: SenRideColors.flagGreen)),
          Expanded(
            child: ColoredBox(
              color: SenRideColors.yellow,
              child: Center(
                child: Transform.scale(
                  scale: .72,
                  child: const Icon(Icons.star,
                      size: 12, color: SenRideColors.flagGreen),
                ),
              ),
            ),
          ),
          const Expanded(child: ColoredBox(color: SenRideColors.flagRed)),
        ]),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  final TextEditingController departController;
  final TextEditingController arriveeController;
  final bool loadingLocation;
  final VoidCallback onLocation;
  final VoidCallback onSearch;
  final VoidCallback onPublish;

  const _SearchPanel({
    required this.departController,
    required this.arriveeController,
    required this.loadingLocation,
    required this.onLocation,
    required this.onSearch,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SenRideColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SenRideColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x66030E12), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(children: [
        _LocationField(
          controller: departController,
          label: 'DÉPART',
          hint: 'Dakar — Sandaga',
          color: SenRideColors.aqua,
          trailing: loadingLocation
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  tooltip: 'Ma position',
                  onPressed: onLocation,
                  icon: const Icon(Icons.my_location,
                      size: 19, color: SenRideColors.aqua),
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 11,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: SenRideColors.border)),
              ),
            ),
          ),
        ),
        _LocationField(
          controller: arriveeController,
          label: 'ARRIVÉE',
          hint: 'Saint-Louis — Centre',
          color: SenRideColors.green,
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: SenRideColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.search, size: 20),
              label: const Text('Chercher',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onPublish,
              style: ElevatedButton.styleFrom(
                backgroundColor: SenRideColors.aqua,
                foregroundColor: const Color(0xFF071D24),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.directions_car, size: 20),
              label: const Text('Proposer',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Color color;
  final Widget? trailing;

  const _LocationField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.location_on_outlined, color: color, size: 20),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: .35)),
            filled: true,
            fillColor: SenRideColors.field,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            suffixIcon: trailing,
          ),
        ),
      ),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
        TextButton(
          onPressed: () {},
          child: const Text('Tout voir',
              style: TextStyle(color: SenRideColors.aqua, fontSize: 13)),
        ),
      ],
    );
  }
}

/// Cartes de trajets populaires (données de démonstration).
/// Remplace par Firestore quand tu actives Firebase.
class _PopularRidesPlaceholder extends StatelessWidget {
  final VoidCallback onSearch;
  const _PopularRidesPlaceholder({required this.onSearch});

  static const _rides = [
    _DemoRide('Dakar', 'Saint-Louis', '14:00', '4 places', '3 500 FCFA'),
    _DemoRide('Dakar', 'Thiès', '08:30', '3 places', '2 000 FCFA'),
    _DemoRide('Dakar', 'Touba', '06:00', '2 places', '2 500 FCFA'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rides
          .map((r) => _PopularRideCard(ride: r, onTap: onSearch))
          .toList(),
    );
  }
}

class _DemoRide {
  final String from;
  final String to;
  final String time;
  final String seats;
  final String price;
  const _DemoRide(this.from, this.to, this.time, this.seats, this.price);
}

class _PopularRideCard extends StatelessWidget {
  final _DemoRide ride;
  final VoidCallback onTap;
  const _PopularRideCard({required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: SenRideColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SenRideColors.border),
            ),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: SenRideColors.green.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car_filled,
                    color: SenRideColors.green, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${ride.from} → ${ride.to}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 3),
                    Text('${ride.time} · ${ride.seats}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .55),
                            fontSize: 12)),
                  ],
                ),
              ),
              Text(ride.price,
                  style: const TextStyle(
                      color: SenRideColors.yellow,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
            ]),
          ),
        ),
      ),
    );
  }
}
