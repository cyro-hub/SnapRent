import 'package:flutter/material.dart';
import '../../components/safe_scaffold.dart';
import 'package:snap_rent/components/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> locations = ['Buea', 'Limbe', 'Douala', 'Yaoundé'];
  String selectedLocation = 'Buea';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🗺️ Dropdown + Filter Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.indigo),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    value: selectedLocation,
                    underline: const SizedBox(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedLocation = newValue!;
                      });
                    },
                    items: locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.filter_alt_outlined,
                  color: Colors.indigo,
                  size: 28,
                ),
                onPressed: () {
                  // TODO: Open filter options
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔍 Search Bar
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
          ),

          const SizedBox(height: 16),

          // 🏘️ Placeholder for property cards
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Replace with dynamic data later
              itemBuilder: (context, index) {
                return PropertyCard(
                  imageUrl:
                      'https://images.pexels.com/photos/8146320/pexels-photo-8146320.jpeg',
                  propertyType: 'Apartment',
                  price: 1200,
                  size: '120',
                  title: 'Modern City View Apartment',
                  description:
                      'This beautiful apartment comes with an open kitchen, bright living room, and a stunning view of the city skyline. Perfect for young professionals...',
                  rating: 4.5,
                  propertyId: "test",
                  hasAccess: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
