import 'package:flutter/material.dart';
import '../Screens//fake_call_screen.dart'; // Import the FakeCallScreen

class GridButtonCards extends StatelessWidget {
  final BuildContext parentContext; // To access the navigation

  const GridButtonCards({
    Key? key,
    required this.parentContext,
  }) : super(key: key);

  Widget _buildCard({
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () {
        if (label == "Fake Call") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FakeCallScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label tapped')),
          );
          // Add your specific logic for other buttons here
          if (label == "Live Location") {
            // Navigate to live location screen/functionality
          } else if (label == "Community Support") {
            // Navigate to community support screen/functionality
          } else if (label == "Settings") {
            // Navigate to settings screen
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD7C3DD),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 4,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF58465B)),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF58465B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.6,
        children: [
          _buildCard(
            icon: Icons.phone,
            label: "Fake Call",
            context: parentContext,
          ),
          _buildCard(
            icon: Icons.location_on,
            label: "Live Location",
            context: parentContext,
          ),
          _buildCard(
            icon: Icons.people,
            label: "Community Support",
            context: parentContext,
          ),
          _buildCard(
            icon: Icons.settings,
            label: "Settings",
            context: parentContext,
          ),
        ],
      ),
    );
  }
}