import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:snap_rent/screens/property_screen.dart';
import 'package:app_settings/app_settings.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Location _location = Location();
  final MapController _mapController = MapController();

  LatLng _currentLocation = const LatLng(4.0511, 9.7679); // Default Cameroon
  List<Marker> _propertyMarkers = [];
  Timer? _debounce;
  String? _locationError;
  bool _isLoading = true;
  bool _isMounted = true; // avoid setState after dispose

  int _retryCount = 0;
  final int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _handleLocationAccess(),
    );
  }

  Future<void> _handleLocationAccess() async {
    if (!_isMounted) return;
    setState(() {
      _isLoading = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _setLocationError(
            'Location services are turned off. Please enable them.',
          );
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted == PermissionStatus.denied) {
          _setLocationError('Location permission denied. Please grant access.');
          return;
        }
      }

      if (permissionGranted == PermissionStatus.deniedForever) {
        _setLocationError(
          'Location permission permanently denied. Open settings to allow access.',
        );
        return;
      }

      final locationData = await _location.getLocation();
      print("LocationData: $locationData");
      if (locationData.latitude == null || locationData.longitude == null) {
        if (_retryCount < _maxRetries) {
          _retryCount++;
          Future.delayed(const Duration(seconds: 1), _handleLocationAccess);
        } else {
          _setLocationError(
            'Unable to fetch your location. Please try again later.',
          );
        }
        return;
      }

      final userPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      if (!_isMounted) return;
      setState(() {
        _currentLocation = userPosition;
        _locationError = null;
        _isLoading = false;
      });

      _mapController.move(userPosition, 17);
      _fetchPropertiesAround(userPosition);
    } catch (e) {
      _setLocationError('An error occurred while accessing location: $e');
    }
  }

  void _setLocationError(String message) {
    if (!_isMounted) return;
    setState(() {
      _locationError = message;
      _isLoading = false;
    });
  }

  void _fetchPropertiesAround(LatLng center) {
    // This can later be replaced with an API call
    setState(() {
      _propertyMarkers = [
        Marker(point: center, width: 50, height: 50, child: const SizedBox()),
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
            const Icon(Icons.location_on),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          // Map Display
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentLocation,
              zoom: 15,
              interactiveFlags: InteractiveFlag.all,
              onPositionChanged: (MapPosition pos, bool hasGesture) {
                if (!_isMounted) return;
                if (hasGesture) {
                  if (_isLoading) {
                    setState(() => _isLoading = false);
                  }
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 700), () {
                    if (pos.center != null) {
                      _fetchPropertiesAround(pos.center!);
                    }
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: _propertyMarkers),
            ],
          ),

          // Location Error UI
          if (_locationError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 60,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _locationError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_locationError!.toLowerCase().contains(
                          "settings",
                        )) {
                          AppSettings.openAppSettings();
                        } else {
                          _retryCount = 0;
                          _handleLocationAccess();
                        }
                      },
                      child: Text(
                        _locationError!.toLowerCase().contains("settings")
                            ? "Open Settings"
                            : "Try Again",
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Map Loading UI
          if (_isLoading)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 12),
                        Text(
                          "Loading map...",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
