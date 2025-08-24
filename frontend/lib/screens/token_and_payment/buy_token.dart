import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snap_rent/services/api_service.dart';
import 'package:snap_rent/widgets/safe_scaffold.dart';
import 'package:snap_rent/widgets/snack_bar.dart';

class BuyTokenScreen extends StatefulWidget {
  const BuyTokenScreen({super.key});

  @override
  State<BuyTokenScreen> createState() => _BuyTokenScreenState();
}

class _BuyTokenScreenState extends State<BuyTokenScreen> {
  int quantity = 1; // Default quantity
  int hours = 24; // Default duration in hours

  double basePricePerToken = 250; // Price per 24h token

  final api = ApiService();

  double get totalPrice {
    return (basePricePerToken * quantity) * (hours / 24);
  }

  DateTime get expiryTime {
    return DateTime.now().add(Duration(hours: hours));
  }

  Future<void> _buyToken(BuildContext context) async {
    try {
      final tokenDetails = {"hours": hours, "quantity": quantity};

      final response = await api.post('token', tokenDetails, context);

      if (response != null && response['data'] != null) {
        SnackbarHelper.show(context, "Token Purchase successfully");
      } else {
        SnackbarHelper.show(
          context,
          "Failed to save property.",
          success: false,
        );
      }
    } catch (e) {
      SnackbarHelper.show(context, "Error: $e", success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.indigo,
                          ),
                          onPressed: () {
                            if (quantity > 1) setState(() => quantity--);
                          },
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.indigo,
                          ),
                          onPressed: () => setState(() => quantity++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Duration Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.timer, color: Colors.indigo),
                        Text(
                          '$hours hours',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.indigo,
                        inactiveTrackColor: Colors.indigo.shade100,
                        thumbColor: Colors.indigo,
                        overlayColor: Colors.indigo.withOpacity(0.2),
                        valueIndicatorColor: Colors.indigo,
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Slider(
                        value: hours.toDouble(),
                        min: 24,
                        max: 168,
                        divisions: 7,
                        label: '$hours h',
                        onChanged: (value) =>
                            setState(() => hours = value.toInt()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Total Price + Expiry Preview
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Total Price: ${totalPrice.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expires at: ${DateFormat('dd MMM yyyy, hh:mm a').format(expiryTime)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Buy Button
            ElevatedButton.icon(
              onPressed: () {
                _buyToken(context);
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Buy Token', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
