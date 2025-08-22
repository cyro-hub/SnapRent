import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../widgets/safe_scaffold.dart';
import '../../widgets/property_widgets/access_property_card.dart';
import 'package:flutter/src/material/stepper.dart';

class MyAccessScreen extends StatefulWidget {
  const MyAccessScreen({super.key});

  @override
  State<MyAccessScreen> createState() => _MyAccessScreenState();
}

class _MyAccessScreenState extends State<MyAccessScreen> {
  int _index = 0;

  final List<Map<String, dynamic>> properties = [
    {
      'propertyId': 'p1',
      'title': 'Modern 2 Bedroom Apartment',
      'image':
          'https://images.pexels.com/photos/8146320/pexels-photo-8146320.jpeg',
      'price': 120000,
      'landmark': 'Near Central Market',
      'town': 'Douala',
      'expiresIn': DateTime.now().add(const Duration(days: 1)),
    },
    {
      'propertyId': 'p2',
      'title': 'Cozy Studio',
      'image':
          'https://images.pexels.com/photos/8146320/pexels-photo-8146320.jpeg',
      'price': 80000,
      'landmark': 'Beside City Mall',
      'town': 'Yaoundé',
      'expiresIn': DateTime.now().add(const Duration(days: 3)),
    },
    {
      'propertyId': 'p3',
      'title': 'Luxury Villa',
      'image':
          'https://images.pexels.com/photos/8146320/pexels-photo-8146320.jpeg',
      'price': 350000,
      'landmark': 'Near Golf Course',
      'town': 'Bafoussam',
      'expiresIn': DateTime.now().add(const Duration(days: 1)),
    },
    {
      'propertyId': 'p4',
      'title': 'Charming Loft',
      'image':
          'https://images.pexels.com/photos/8146320/pexels-photo-8146320.jpeg',
      'price': 200000,
      'landmark': 'Hilltop Road',
      'town': 'Buea',
      'expiresIn': DateTime.now().add(const Duration(days: 5)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Sort by expiry (soonest first)
    final sorted = [...properties]
      ..sort((a, b) => a['expiresIn'].compareTo(b['expiresIn']));

    // Group by expiry string (e.g., "in 1 day")
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var prop in sorted) {
      final key = timeago.format(prop['expiresIn'], allowFromNow: true);
      grouped.putIfAbsent(key, () => []).add(prop);
    }

    return SafeScaffold(
      child: Stepper(
        currentStep: _index,
        onStepTapped: (int index) {
          setState(() {
            _index = index;
          });
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return const SizedBox.shrink(); // hides the buttons
        },
        steps: grouped.entries.map((entry) {
          final expiryText = entry.key;
          final props = entry.value;

          return Step(
            title: Text("Expires $expiryText"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: props.map((prop) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AccessPropertyCard(
                    propertyId: prop['propertyId'],
                    title: prop['title'],
                    image: prop['image'],
                    rentAmount: prop['price'],
                    landmark: prop['landmark'],
                    town: prop['town'],
                    rentCurrency: "FCFA",
                    paymentFrequency: "Monthly",
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
