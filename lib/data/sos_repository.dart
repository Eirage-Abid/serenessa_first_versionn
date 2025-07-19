import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serenessa_first_version/data/location_service.dart';
import 'package:url_launcher/url_launcher.dart'; // REQUIRED for opening native apps

class SOSRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String>> _fetchEmergencyContacts() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          // Ensure emergencyContacts is stored as a List<String> in Firestore.
          // IMPORTANT: For WhatsApp, these numbers should be in full international format (e.g., +923001234567).
          // For SMS, the format can be more flexible, but international is best practice.
          return List<String>.from(data?['emergencyContacts'] as List<dynamic>? ?? []);
        }
      } catch (e) {
        print("Error fetching emergency contacts from Firestore: $e");
      }
    } else {
      print("No user logged in to fetch emergency contacts.");
    }
    return [];
  }

  Future<void> sendSOS() async {
    print("SOSRepository: sendSOS() called.");

    final List<String> contacts = await _fetchEmergencyContacts();
    print("SOSRepository: Contacts fetched: $contacts");

    if (contacts.isEmpty) {
      print("SOSRepository: No emergency contacts found.");
      throw Exception("No emergency contacts configured. Please add contacts in your details.");
    }

    String location = await LocationService.getCurrentLocation();
    print("SOSRepository: Location fetched: $location");
    String message = "🚨 SOS Alert! I need help. My location: $location";

    print("SOSRepository: Preparing to open messaging apps for: $contacts");
    print("Message: $message");

    List<String> failedLaunches = [];

    for (String contact in contacts) {
      // Determine if it's a WhatsApp number or a regular SMS number
      // We'll assume if it starts with 'whatsapp:' or contains characters that indicate a URL,
      // it's for WhatsApp, otherwise, it's for SMS.
      // For simplicity, let's assume direct phone numbers are SMS unless explicitly formatted for WhatsApp.
      // If your Firestore stores WhatsApp numbers with a 'whatsapp:' prefix, adapt this logic.
      if (contact.startsWith('whatsapp:') || contact.contains('wa.me')) { // Basic check for WhatsApp
        await _launchWhatsApp(contact, message, failedLaunches);
      } else {
        await _launchSMS(contact, message, failedLaunches);
      }
    }

    if (failedLaunches.isNotEmpty) {
      throw Exception("Failed to open messaging app for some contacts: ${failedLaunches.join(', ')}. Please check numbers and if apps are installed.");
    }
    print("SOSRepository: All messaging apps attempted to launch.");
    print("NOTE: The user must manually press 'Send' in each opened app.");
  }

  /// Helper method to launch the native SMS app.
  Future<void> _launchSMS(String phoneNumber, String message, List<String> failedList) async {
    final Uri smsUri = Uri.parse("sms:$phoneNumber?body=${Uri.encodeComponent(message)}");
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        print("SMS app launched for $phoneNumber.");
        // Add a slight delay to allow the OS to process before opening the next app
        await Future.delayed(Duration(seconds: 1));
      } else {
        print("Could not launch SMS app for $phoneNumber. No SMS app available or invalid number format.");
        failedList.add(phoneNumber);
      }
    } catch (e) {
      print("Error launching SMS app for $phoneNumber: $e");
      failedList.add(phoneNumber);
    }
  }

  /// Helper method to launch the WhatsApp app.
  Future<void> _launchWhatsApp(String contact, String message, List<String> failedList) async {
    // If contact is stored as 'whatsapp:+923xxxxxxxxx', extract the number
    String phoneNumber = contact;
    if (contact.startsWith('whatsapp:')) {
      phoneNumber = contact.replaceFirst('whatsapp:', '');
    }

    // Use the wa.me link for better cross-platform compatibility
    final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication); // Prefer external app launch
        print("WhatsApp app launched for $phoneNumber.");
        // Add a slight delay to allow the OS to process before opening the next app
        await Future.delayed(Duration(seconds: 1));
      } else {
        print("Could not launch WhatsApp app for $phoneNumber. WhatsApp not installed or invalid number format.");
        failedList.add(phoneNumber);
      }
    } catch (e) {
      print("Error launching WhatsApp app for $phoneNumber: $e");
      failedList.add(phoneNumber);
    }
  }
}