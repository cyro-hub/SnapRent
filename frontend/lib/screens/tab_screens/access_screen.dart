import 'package:flutter/material.dart';
import 'package:snap_rent/services/api_service.dart';
import 'package:snap_rent/widgets/snack_bar.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../widgets/safe_scaffold.dart';
import '../../widgets/property_widgets/access_property_card.dart';

class MyAccessScreen extends StatefulWidget {
  const MyAccessScreen({super.key});

  @override
  State<MyAccessScreen> createState() => _MyAccessScreenState();
}

class _MyAccessScreenState extends State<MyAccessScreen>
    with WidgetsBindingObserver {
  int _index = 0;
  final api = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Run first fetch
    fetchProperties(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refetch whenever app is resumed
      setState(() {});
    }
  }

  /// Fetch properties from backend
  Future<List<Map<String, dynamic>>> fetchProperties(
    BuildContext context,
  ) async {
    try {
      final response = await api.get('properties/token', context, {});

      if (response != null && response['data'] != null) {
        return List<Map<String, dynamic>>.from(
          response['data'].map((p) {
            // convert hours => DateTime for timeago
            final expiresAt = DateTime.now().add(
              Duration(hours: (p['expiresIn'] as num).toInt()),
            );

            return {
              'propertyId': p['propertyId'],
              'tokenPackageId': p['tokenPackageId'].toString(),
              'title': p['title'],
              'image': p['image'],
              'rentAmount': p['rentAmount'],
              'currency': p['currency'] ?? 'FCFA',
              'landmark': p['landmark'],
              'town': p['town'],
              'expiresAt': expiresAt,
              'isExpired': p['isExpired'] ?? false,
            };
          }),
        );
      } else {
        SnackbarHelper.show(context, "No properties available.");
        return [];
      }
    } catch (e) {
      SnackbarHelper.show(context, "Error: $e", success: false);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchProperties(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No properties found'));
          }

          final properties = snapshot.data!;

          // Sort by expiry date
          final sorted = [...properties]
            ..sort(
              (a, b) => (a['expiresAt'] as DateTime).compareTo(
                b['expiresAt'] as DateTime,
              ),
            );

          // Group by expiry string (e.g. "in 7 hours")
          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (var prop in sorted) {
            final key = prop['isExpired'] == true
                ? "Expired"
                : timeago.format(prop['expiresAt'], allowFromNow: true);
            grouped.putIfAbsent(key, () => []).add(prop);
          }

          return Stepper(
            currentStep: _index,
            onStepTapped: (int index) {
              setState(() {
                _index = index;
              });
            },
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return const SizedBox.shrink();
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
                        tokenPackageId: prop['tokenPackageId'],
                        title: prop['title'],
                        image: prop['image'],
                        rentAmount: prop['rentAmount'],
                        rentCurrency: prop['currency'],
                        expiresIn: prop['expiresAt'], // still DateTime for card
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
