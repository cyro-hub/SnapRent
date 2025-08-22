import 'package:flutter/material.dart';
import 'package:snap_rent/core/constant.dart';
import "package:snap_rent/screens/property_screens/property_screen.dart";
import 'package:snap_rent/widgets/screen_guard.dart';

class PropertyCard extends StatelessWidget {
  final String image;
  final String propertyId;
  final String type;
  final int rentAmount;
  final String size;
  final String title;
  final String description;
  final double rating;
  final bool hasAccess;
  final String currency;
  final String paymentFrequency;

  const PropertyCard({
    super.key,
    required this.paymentFrequency,
    required this.currency,
    required this.propertyId,
    required this.image,
    required this.type,
    required this.rentAmount,
    required this.size,
    required this.title,
    required this.description,
    required this.rating,
    required this.hasAccess,
  });

  String _shorten(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Type + Size Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$size m²',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // Price
                Text(
                  "$currency ${formatPrice(rentAmount)} / $paymentFrequency",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 8),

                // Short Description
                Text(
                  _shorten(description, maxLength: 100),
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),

                const SizedBox(height: 12),

                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Rating',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ScreenGuard(
                                screen: PropertyScreen(propertyId: propertyId),
                              ),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(hasAccess ? Icons.lock_open : Icons.lock),
                            const SizedBox(width: 8),
                            const Text("View"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
