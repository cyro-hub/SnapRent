import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../property_screens/property_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Location _location = Location();
  final MapController _mapController = MapController();

  // Default location (Cameroon)
  LatLng _currentLocation = const LatLng(4.0511, 9.7679);
  List<Marker> _propertyMarkers = [];
  bool _isSearching = false; // Loading overlay only when searching

  Timer? _debounce; // debounce for map panning
  LatLng?
  _lastFetchCenter; // store last fetched center to avoid fetching on zoom

  @override
  void initState() {
    super.initState();

    // Load default properties immediately
    _fetchPropertiesAround(_currentLocation);

    // Try to get user location silently
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserLocationSilently();
    });
  }

  /// Try fetching user location silently; fallback to default without showing errors
  Future<void> _loadUserLocationSilently() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return; // fallback to default silently
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted)
          return; // fallback silently
      }

      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        final userPos = LatLng(locationData.latitude!, locationData.longitude!);

        // Move map to user location and fetch nearby properties
        setState(() {
          _currentLocation = userPos;
        });
        _mapController.move(userPos, 17);
        _fetchPropertiesAround(userPos);
      }
    } catch (_) {
      // Ignore errors silently and continue with default
    }
  }

  /// Fetch properties around a location (no center marker)
  void _fetchPropertiesAround(LatLng center) {
    setState(() {
      _propertyMarkers = [
        Marker(
          point: LatLng(center.latitude + 0.0002, center.longitude + 0.0002),
          width: 40,
          height: 40,
          child: _propertyMarker("property_1"),
        ),
        Marker(
          point: LatLng(center.latitude - 0.002, center.longitude - 0.002),
          width: 40,
          height: 40,
          child: _propertyMarker("property_2"),
        ),
      ];
    });
  }

  Widget _propertyMarker(String id) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PropertyScreen(propertyId: id)),
        );
      },
      child: Image.asset(
        "assets/marker_icons/marker.png",
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.location_on, color: Colors.red),
      ),
    );
  }

  /// Called when user searches
  void _searchProperties(String query) async {
    setState(() => _isSearching = true);

    // Simulate search API call
    await Future.delayed(const Duration(seconds: 1));

    print("Searching properties for: $query");

    // Example: Update markers based on search
    setState(() {
      _propertyMarkers = [
        Marker(
          point: LatLng(
            _currentLocation.latitude + 0.001,
            _currentLocation.longitude + 0.001,
          ),
          width: 40,
          height: 40,
          child: _propertyMarker("search_result_1"),
        ),
      ];
      _isSearching = false;
    });
  }

  double _distanceBetween(LatLng a, LatLng b) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;
    return sqrt(dx * dx + dy * dy);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation,
                zoom: 15,
                interactiveFlags: InteractiveFlag.all,
                onPositionChanged: (pos, hasGesture) {
                  if (hasGesture && pos.center != null) {
                    // Only fetch if center moved significantly
                    if (_lastFetchCenter == null ||
                        _distanceBetween(_lastFetchCenter!, pos.center!) >
                            0.0005) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 700), () {
                        _lastFetchCenter = pos.center!;
                        _fetchPropertiesAround(pos.center!);
                      });
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bongsco.app',
                ),
                MarkerLayer(markers: _propertyMarkers),
              ],
            ),
          ),

          // Green overlay
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(color: Colors.green.withOpacity(0.4)),
            ),
          ),

          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 12,
            right: 12,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.6),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search property...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
                onSubmitted: _searchProperties,
              ),
            ),
          ),

          // Loading overlay only when searching
          if (_isSearching)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
