import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../components/safe_scaffold.dart';
import '../../components/access_property_card.dart';

class MyAccessScreen extends StatelessWidget {
  MyAccessScreen({super.key});

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

    // Group by expiry string (e.g., "in 2 days")
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var property in sorted) {
      final key = timeago.format(property['expiresIn'], allowFromNow: true);
      grouped.putIfAbsent(key, () => []).add(property);
    }

    return SafeScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: grouped.entries.map((entry) {
            final group = entry.value;

            return Stack(
              children: [
                // Blue vertical line
                Positioned(
                  left: 8,
                  top: 36,
                  bottom: 30,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(215, 63, 81, 181),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // Group content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expires header
                    Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 8),
                      child: Text(
                        'Expires ${entry.key}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Cards
                    Column(
                      children: group.map((prop) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 24),
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
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
