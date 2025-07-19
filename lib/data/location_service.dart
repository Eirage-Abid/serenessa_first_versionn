import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<String> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return "Location not available";

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "Location permission denied";
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    return "https://maps.google.com/?q=${position.latitude},${position.longitude}";
  }
}
