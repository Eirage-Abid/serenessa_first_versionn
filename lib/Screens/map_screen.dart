import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:serenessa_first_version/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = true;

  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (!await _checkRequestPermissions()) return;

    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          isLoading = false;
        });
      }
    });
  }

  Future<void> fetchCoordinatesPoint(String location) async {
    final url = Uri.parse(
    // "   https://nominatim.openstreetmap.org/search?q=encodedLocation&format=json&limit=1");
        "https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _destination = LatLng(lat, lon);
        });
        await fetchRoute();
      } else {
        errorMessage('Location not found, try another location');
      }
    } else {
      errorMessage("Failed to fetch location, Try again later");
    }
  }



  /**
  Future<void> fetchCoordinatesPoint(String location) async {
    final encodedLocation = Uri.encodeComponent(location); // Encode spaces
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$encodedLocation&format=json&limit=1");

    final response = await http.get(url);

    print("Geocoding API Response: ${response.body}"); // Debugging output

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _destination = LatLng(lat, lon);
        });
        await fetchRoute();
      } else {
        errorMessage('Location not found, try another location');
      }
    } else {
      errorMessage("Failed to fetch location, Try again later");
    }
  }
  Future<void> fetchCoordinatesPoint(String location) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        double lat = double.parse(data[0]['lat']);
        double lon = double.parse(data[0]['lon']);
        print("Fetched Coordinates: Lat = $lat, Lon = $lon");

        setState(() {
          _destination = LatLng(lat, lon);

          // ✅ Add a manual polyline from a fixed point for testing
          _route = [
            _currentLocation ?? LatLng(30.3308401, 71.247499), // Your starting point
            LatLng(lat, lon),  // API response destination
            LatLng(lat + 0.01, lon + 0.01) // A nearby point to extend the line
          ];
        });
      } else {
        print("No location data found.");
      }
    } else {
      print("Failed to fetch coordinates.");
    }
  }**/

  // Method to fetch the route between the current location and the destination using the OSRM API

  Future<void> fetchRoute() async {
    /*  if (_currentLocation == null )  { print("Destination set to: $_destination");
    return;}*/
    if (_currentLocation == null || _destination == null) return;
    final url = Uri.parse(
        "http://router.project-osrm.org/route/v1/driving/"
            '${_currentLocation!.longitude},${_currentLocation!.latitude};'
            '${_destination!.longitude},${_destination!
            .latitude}?overview=full&geometries=polyline',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodedPolyline(geometry);
    } else {
      errorMessage("Failed to fetch route, try again later");
    }
  }

  // Let's decode the polyline string into  geometric list of coordinates
  void _decodedPolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoints =
    polylinePoints.decodePolyline(encodedPolyline);

    setState(() {
      _route = decodedPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    });
  }

  Future<bool> _checkRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    return true;
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Current Location not available."),
        ),
      );
    }
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("OpenStreet Map"),
        backgroundColor: AppColors.primary,
      ),*/
      body: Stack(
        children: [
          // Loading indicator
          isLoading? const Center(
            child: CircularProgressIndicator(),
          ):
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? LatLng(0, 0),
              initialZoom: 13.0,
              maxZoom: 19,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png?lang=en",
              ),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: const Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),

              if(_destination != null)
                MarkerLayer(
                  markers: [
                    Marker(
                        point: _destination!,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_pin,
                          size: 40,
                          color: Colors.red,
                        ))
                  ],
                ),
              if (_currentLocation != null && _destination != null && _route.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(
                      points: _route,
                  strokeWidth : 5,
                    color: Colors.red,
                  )
                ])
            ],
          ),
          Positioned(
            top: 20,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        hintText: "Enter your location",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),

                  //IconButton to trigger the search for the entered location
                  IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white
                      ),
                      onPressed: (){
                        final location = _locationController.text.trim();
                        if(location.isNotEmpty){
                          fetchCoordinatesPoint(location);
                        }
                      },

                      icon:  const Icon(Icons.search)),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: _userCurrentLocation,
        backgroundColor: AppColors.white,
        child: const Icon(
          Icons.my_location,
          size: 30,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
