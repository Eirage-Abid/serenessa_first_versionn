import 'package:flutter/material.dart';

class HomeCardsSection extends StatelessWidget {
  // NEW: Add callbacks for each card tap
  final VoidCallback onPoliceTap;
  final VoidCallback onHospitalTap;
  final VoidCallback onEmergencyContactsTap;
  final bool isLocating; // NEW: To pass the loading state for location

  const HomeCardsSection({
    Key? key,
    required this.onPoliceTap,
    required this.onHospitalTap,
    required this.onEmergencyContactsTap,
    required this.isLocating, // Required for the loading indicator
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Access",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B3B4E),
            ),
          ),
          const SizedBox(height: 16),
          // NEW: Use onTap for each card
          _buildCardd(
            icon: Icons.local_police_outlined,
            title: "Police Station near me",
            subtitle: "Find nearest police station with address, phone & directions.",
            context: context,
            onTap: onPoliceTap, // Pass the callback
            isLoading: isLocating, // Pass loading state
          ),
          const SizedBox(height: 16),
          _buildCardd(
            icon: Icons.local_hospital_outlined,
            title: "Hospital near me",
            subtitle: "Locate nearby hospitals, clinics & medical facilities with contact info.",
            context: context,
            onTap: onHospitalTap, // Pass the callback
            isLoading: isLocating, // Pass loading state
          ),
          const SizedBox(height: 16),
          _buildCardd(
            icon: Icons.contact_emergency_outlined,
            title: "Emergency Contacts",
            subtitle: "Store & quickly access important phone numbers.",
            context: context,
            onTap: onEmergencyContactsTap, // Pass the callback
            isLoading: false, // Emergency contacts likely don't need location
          ),
        ],
      ),
    );
  }

  Widget _buildCardd({
    required IconData icon,
    required String title,
    required String subtitle,
    required BuildContext context,
    required VoidCallback onTap, // NEW: Add onTap callback
    required bool isLoading, // NEW: Add isLoading flag
  }) {
    return GestureDetector( // Use GestureDetector to make the entire card tappable
      onTap: isLoading ? null : onTap, // Disable tap if loading
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E2EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF6A4C93)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B3B4E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Optional: Show a loading indicator on the card itself when fetching location
              isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
                  : const Icon(Icons.arrow_forward_ios, color: Colors.grey), // Changed to arrow for consistency
            ],
          ),
        ),
      ),
    );
  }
}