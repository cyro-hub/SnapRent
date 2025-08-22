import 'package:flutter/material.dart';

Widget buildLocationAndContact(Map<dynamic, dynamic> propertyData) {
  final location = propertyData['location'];
  final contact = propertyData['contact'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      const Text(
        "Location Details",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationRow(Icons.location_city, "Town", location['town']),
              _locationRow(Icons.apartment, "Quarter", location['quarter']),
              _locationRow(
                Icons.sports_score_outlined,
                "Street",
                location['street'],
              ),
              _locationRow(Icons.place, "Landmark", location['landmark']),
              _locationRow(
                Icons.map,
                "Coordinates",
                "Lat: ${location['coordinates'][1]}, Lng: ${location['coordinates'][0]}",
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        "Contact Agent",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationRow(Icons.person, "Agent", contact['agentName']),
              _locationRow(Icons.phone, "Phone", contact['phone']),
              _locationRow(Icons.message, "WhatsApp", contact['whatsapp']),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _locationRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Flexible(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    ),
  );
}
