import 'package:flutter/material.dart';
import 'package:snap_rent/core/constant.dart';
import 'package:snap_rent/screens/property_screens/property_screen.dart';

class AccessPropertyCard extends StatelessWidget {
  final String propertyId;
  final String title;
  final String image;
  final int rentAmount;
  final String landmark;
  final String town;
  final String rentCurrency;
  final String paymentFrequency;

  const AccessPropertyCard({
    super.key,
    required this.propertyId,
    required this.title,
    required this.image,
    required this.rentAmount,
    required this.landmark,
    required this.town,
    required this.rentCurrency,
    required this.paymentFrequency,
  });

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyScreen(propertyId: propertyId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToDetails(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Dark gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Property details
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$rentCurrency ${formatPrice(rentAmount)} / $paymentFrequency',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "$landmark, $town",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
