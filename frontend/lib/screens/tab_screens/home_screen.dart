import 'package:flutter/material.dart';
import 'package:snap_rent/services/api_service.dart';
import 'package:snap_rent/widgets/snack_bar.dart';
import '../../widgets/safe_scaffold.dart';
import 'package:snap_rent/widgets/property_widgets/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> locations = ['Buea', 'Limbe', 'Douala', 'Yaoundé'];

  List<Map<String, dynamic>> properties = [];

  String? selectedLocation; // start null or empty
  String? searchQuery;
  String? selectedPropertyType;
  String? maxRent;
  String? paymentFrequency;

  String? toilet;
  String? bathroom;
  String? kitchen;

  bool? waterAvailable;
  bool? electricity;
  bool? parking;

  final api = ApiService();

  @override
  void initState() {
    super.initState();
    fetchProperties(); // fetch without filters at first load
  }

  Map<String, String> buildQueryParameters() {
    final Map<String, String> queryParams = {};

    void addIfNotEmpty(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is bool) {
        if (value == false)
          return; // or include false if you want explicit false filter
        queryParams[key] = value.toString();
        return;
      }
      queryParams[key] = value.toString();
    }

    addIfNotEmpty('location', selectedLocation);
    addIfNotEmpty('search', searchQuery);
    addIfNotEmpty('type', selectedPropertyType);
    addIfNotEmpty('maxRent', maxRent);
    addIfNotEmpty('paymentFrequency', paymentFrequency);

    addIfNotEmpty('toilet', toilet);
    addIfNotEmpty('bathroom', bathroom);
    addIfNotEmpty('kitchen', kitchen);

    addIfNotEmpty('waterAvailable', waterAvailable);
    addIfNotEmpty('electricity', electricity);
    addIfNotEmpty('parking', parking);

    return queryParams;
  }

  Future<void> _openFilterDrawer() async {
    final screenHeight = MediaQuery.of(context).size.height;

    // Nullable local vars initialized with current filter state
    String? propertyType = selectedPropertyType;
    String? localMaxRent = maxRent;
    String? localPaymentFrequency = paymentFrequency;

    String? localToilet = toilet;
    String? localBathroom = bathroom;
    String? localKitchen = kitchen;

    bool? localWaterAvailable = waterAvailable;
    bool? localElectricity = electricity;
    bool? localParking = parking;

    final List<String> propertyTypes = [
      'Apartment',
      'House',
      'Studio',
      'Office',
    ];

    final maxRentController = TextEditingController(text: localMaxRent);

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Sync controller changes to localMaxRent
            maxRentController.addListener(() {
              localMaxRent = maxRentController.text.isEmpty
                  ? null
                  : maxRentController.text;
            });

            return SafeArea(
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.7,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pill handle
                      Center(
                        child: Container(
                          width: 50,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Filter Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text('Property Type'),
                      DropdownButtonFormField<String>(
                        value: propertyType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        items: propertyTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => propertyType = val),
                        // Allow clearing selection?
                      ),

                      const SizedBox(height: 16),

                      const Text('Max Rent'),
                      TextField(
                        controller: maxRentController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter max rent',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          suffixIcon:
                              localMaxRent != null && localMaxRent!.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    maxRentController.clear();
                                    setState(() {
                                      localMaxRent = null;
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text('Payment Frequency'),
                      DropdownButtonFormField<String>(
                        value: localPaymentFrequency,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        items: ['Monthly', 'Quarterly', 'Yearly']
                            .map(
                              (freq) => DropdownMenuItem(
                                value: freq,
                                child: Text(freq),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => localPaymentFrequency = val),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Amenities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text('Toilet'),
                      DropdownButtonFormField<String>(
                        value: localToilet,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        items: ['private', 'shared']
                            .map(
                              (val) => DropdownMenuItem(
                                value: val,
                                child: Text(
                                  val[0].toUpperCase() + val.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => localToilet = val),
                      ),

                      const SizedBox(height: 16),

                      const Text('Bathroom'),
                      DropdownButtonFormField<String>(
                        value: localBathroom,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        items: ['private', 'shared']
                            .map(
                              (val) => DropdownMenuItem(
                                value: val,
                                child: Text(
                                  val[0].toUpperCase() + val.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => localBathroom = val),
                      ),

                      const SizedBox(height: 16),

                      const Text('Kitchen'),
                      DropdownButtonFormField<String>(
                        value: localKitchen,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        items: ['private', 'shared']
                            .map(
                              (val) => DropdownMenuItem(
                                value: val,
                                child: Text(
                                  val[0].toUpperCase() + val.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => localKitchen = val),
                      ),

                      const SizedBox(height: 24),

                      CheckboxListTile(
                        title: const Text('Water Available'),
                        value: localWaterAvailable ?? false,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) =>
                            setState(() => localWaterAvailable = val),
                      ),

                      CheckboxListTile(
                        title: const Text('Electricity'),
                        value: localElectricity ?? false,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) =>
                            setState(() => localElectricity = val),
                      ),

                      CheckboxListTile(
                        title: const Text('Parking'),
                        value: localParking ?? false,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (val) => setState(() => localParking = val),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pop(null); // Cancel filters
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop({
                                  'propertyType': propertyType,
                                  'maxRent': localMaxRent,
                                  'paymentFrequency': localPaymentFrequency,
                                  'toilet': localToilet,
                                  'bathroom': localBathroom,
                                  'kitchen': localKitchen,
                                  'waterAvailable': localWaterAvailable,
                                  'electricity': localElectricity,
                                  'parking': localParking,
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    maxRentController.dispose();

    if (result != null) {
      setState(() {
        selectedPropertyType = result['propertyType'];
        maxRent = result['maxRent'];
        paymentFrequency = result['paymentFrequency'];
        toilet = result['toilet'];
        bathroom = result['bathroom'];
        kitchen = result['kitchen'];
        waterAvailable = result['waterAvailable'];
        electricity = result['electricity'];
        parking = result['parking'];
      });

      fetchProperties();
    }
  }

  Future<void> fetchProperties() async {
    final filters = buildQueryParameters();

    try {
      final data = await api.get('properties/search', filters);

      // Assuming your API returns a JSON object with a list under a key like "properties" or just a list
      List<dynamic> fetchedProperties = [];

      if (data is List) {
        fetchedProperties = data;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        fetchedProperties = data['data'];
      }

      setState(() {
        // Convert dynamic list to List<Map<String, dynamic>>
        properties = List<Map<String, dynamic>>.from(fetchedProperties);
      });
    } catch (e) {
      SnackbarHelper.show(
        context,
        'Error fetching properties: $e',
        success: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location dropdown + Filter icon row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.indigo),
                  const SizedBox(width: 8),
                  DropdownButton<String?>(
                    value: selectedLocation,
                    underline: const SizedBox(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedLocation = newValue;
                      });
                    },
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Location'),
                      ),
                      ...locations.map((location) {
                        return DropdownMenuItem<String?>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),

              IconButton(
                icon: const Icon(
                  Icons.filter_alt_outlined,
                  color: Colors.indigo,
                  size: 28,
                ),
                onPressed: _openFilterDrawer,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search properties...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            onSubmitted: (value) {
              setState(() {
                searchQuery = value;
              });
              fetchProperties();
            },
          ),

          const SizedBox(height: 16),

          // Property cards list placeholder
          Expanded(
            child: properties.isEmpty
                ? Center(child: Text('No properties found'))
                : ListView.builder(
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return PropertyCard(
                        image:
                            (property['images'] != null &&
                                property['images'] is List &&
                                (property['images'] as List).isNotEmpty)
                            ? property['images'][0] ?? ''
                            : '', // Adjust key based on your API
                        type: property['type'] ?? '',
                        rentAmount: property['rentAmount'] ?? 0,
                        size: property['size']?.toString() ?? '',
                        title: property['title'] ?? '',
                        currency: property['currency'] ?? '',
                        paymentFrequency: property['paymentFrequency'] ?? '',
                        description: property['description'] ?? '',
                        rating: (property['rating'] is num)
                            ? property['rating'].toDouble()
                            : 0.0,
                        propertyId: property['_id'] ?? '',
                        hasAccess: property['hasAccess'] ?? false,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
