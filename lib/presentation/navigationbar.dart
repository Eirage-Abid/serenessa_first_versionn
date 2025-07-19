import 'package:flutter/material.dart';
import 'package:serenessa_first_version/theme.dart';

class NavigationBarView extends StatelessWidget {
  final int currentIndexx;
  final ValueChanged<int> onTabChanged;

  const NavigationBarView({
    Key? key,
    required this.currentIndexx,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: 10.0,
      height: 80.0, // Increased height for better visual
      decoration: BoxDecoration(
        color: AppColors.primary, // dark background
        borderRadius: BorderRadius.circular(25.0), // More rounded
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3), // Subtle shadow
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            index: 0,
            isSelected: currentIndexx == 0,
            onTap: onTabChanged,
          ),
          _buildNavItem(
            icon: Icons.location_on_outlined,
            label: 'Location',
            index: 1,
            isSelected: currentIndexx == 1,
            onTap: onTabChanged,
          ),
          _buildSOSNavItem( // Separate widget for SOS
            icon: Icons.sos_rounded,
            label: 'SOS',
            index: 2,
            isSelected: currentIndexx == 2,
            onTap: onTabChanged,
          ),
          _buildNavItem(
            icon: Icons.details_outlined,
            label: 'Details',
            index: 3,
            isSelected: currentIndexx == 3,
            onTap: onTabChanged,
          ),
          _buildNavItem(
            icon: Icons.history_outlined, // Changed to history icon
            label: 'History',
            index: 4,
            isSelected: currentIndexx == 4,
            onTap: onTabChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required ValueChanged<int> onTap,
  }) {
    final Color iconColor = isSelected ? const Color(0xFFFFFFFF) : Colors.grey[600]!; // Primary color when selected
    final TextStyle labelStyle = TextStyle(
      color: iconColor,
      fontSize: 12.0,
    );

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28.0, color: iconColor),
          const SizedBox(height: 4.0),
          Text(label, style: labelStyle),
        ],
      ),
    );
  }

  Widget _buildSOSNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required ValueChanged<int> onTap,
  }) {
    final Color iconColor = const Color(0xFFFFFFFF); // Consistent primary color
    final TextStyle labelStyle = TextStyle(
      color: iconColor,
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
    );

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary, // White circle background
          border: Border.all(color: iconColor, width: 2.0), // Primary color border
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30.0, color: iconColor),
            // The label for SOS can be omitted or styled differently
            // if the circular icon is self-explanatory
            // Text(label, style: labelStyle),
          ],
        ),
      ),
    );
  }
}