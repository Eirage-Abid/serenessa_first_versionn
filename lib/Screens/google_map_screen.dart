import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../presentation/navigationbar.dart'; // Import your navigation bar
import 'Home.dart';
import 'SOS_screen.dart';
import 'edit_details_screen.dart';
import 'edit_profile_screen.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key); // Added key for the constructor

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  int _currentIndexx = 1;
  Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;
  final TextEditingController _destinationController = TextEditingController();
  bool _isLocationServiceEnabled = false;
  LocationPermission? _locationPermission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationServicesAndPermissions();
  }

  // Function to handle navigation tab changes
  void _onTabChanged(int indexx) {
    setState(() {
      _currentIndexx = indexx;
      print('Selected tab: $indexx');
      switch (indexx) {
        case 0:
          var userName;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userName: userName)),
          );
          break;
        case 1:
        // Stay on the GoogleMapScreen
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SosScreen()),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );
          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DetailsScreen()),
          );
          break;
      }
    });
  }


  Future<void> _checkLocationServicesAndPermissions() async {
    _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    _locationPermission = await Geolocator.checkPermission();

    if (!_isLocationServiceEnabled ||
        _locationPermission == LocationPermission.denied ||
        _locationPermission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      _showLocationSettingsDialog();
    } else {
      _determineCurrentPosition();
    }
  }

  Future<void> _determineCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
        _goToCurrentLocation();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error getting current location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get current location.')),
      );
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  Future<void> _searchDestination() async {
    final destination = _destinationController.text;
    if (destination.isEmpty) return;

    setState(() {
      _destinationLocation = null;
      _polylines.clear();
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$destination&format=json&limit=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          _destinationLocation =
              LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
          _isLoading = false;
          _drawPolyline();
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_destinationLocation!, 14),
          );
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destination not found.')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to search destination.')),
      );
    }
  }

  Future<void> _drawPolyline() async {
    if (_currentLocation == null || _destinationLocation == null) return;
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
            '${_currentLocation!.longitude},${_currentLocation!.latitude};'
            '${_destinationLocation!.longitude},${_destinationLocation!.latitude}?overview=full&geometries=polyline');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final geometry = data['routes'][0]['geometry'];
        List<LatLng> routeCoordinates = _decodePolyline(geometry);
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: routeCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          };
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find a route to the destination.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch route.')),
      );
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
  }

  Future<void> _showLocationSettingsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('This app needs location services to function properly.'),
                const Text('Please enable location services in your device settings.'),
                if (_locationPermission == LocationPermission.denied ||
                    _locationPermission == LocationPermission.deniedForever)
                  const Text('\nPlease grant the app location permissions.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                await Geolocator.openAppSettings();
                _checkLocationServicesAndPermissions();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SizedBox( // Make the TextField wider
          width: MediaQuery.of(context).size.width * 0.100, // Adjust the multiplier as needed
          height: 40,
          child: TextField(
            controller: _destinationController,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Where are you going to?',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton( // Add the search icon on the right
                icon: const Icon(Icons.search, color: Colors.blue),
                onPressed: _searchDestination,
              ),
            ),
            onSubmitted: (value) {
              _searchDestination();
            },
          ),
        ),
        centerTitle: true,
        actions: [
          // Removed the FloatingActionButton from the AppBar actions
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_currentLocation != null)
            GoogleMap(
              padding: const EdgeInsets.only(bottom: 80.0),
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: {
                if (_currentLocation != null)
                  Marker(
                    markerId: const MarkerId('currentLocation'),
                    position: _currentLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                  ),
                if (_destinationLocation != null)
                  Marker(
                    markerId: const MarkerId('destinationLocation'),
                    position: _destinationLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
              },
              polylines: _polylines,
            )
          else
            const Center(child: Text('Location not available.')),
          // Current Location Button at the Bottom Right
          Positioned(
            right: 18.0,
            bottom: 20.0, // Adjust this value based on your bottom navigation bar height + desired spacing
            child: FloatingActionButton(
              mini: false, // Make it a regular size button if needed
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    /*  bottomNavigationBar: NavigationBarView(
        currentIndexx: _currentIndexx,
        onTabChanged: _onTabChanged,
      ),*/
    );
  }
}
