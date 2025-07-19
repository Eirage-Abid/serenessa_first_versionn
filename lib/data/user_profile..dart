// lib/models/user_profile.dart
class UserProfile {
  final String? name;
  final String? email;
  final String? phone;
  final List<String> emergencyContacts;
  final List<String> safeZones;

  UserProfile({
    this.name,
    this.email,
    this.phone,
    this.emergencyContacts = const [],
    this.safeZones = const [],
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      emergencyContacts: List<String>.from(data['emergencyContacts'] ?? []),
      safeZones: List<String>.from(data['safeZones'] ?? []),
    );
  }

  // Optionally, a method to get address if you store it as a single string
  String get addressDisplay {
    // You'll need to decide how 'address' is stored.
    // If 'safeZones' is meant to be a kind of address/location, use the first one.
    if (safeZones.isNotEmpty) {
      return safeZones.first; // Or combine multiple safe zones if applicable
    }
    return "Not Available"; // Default if no safe zones/address
  }
}