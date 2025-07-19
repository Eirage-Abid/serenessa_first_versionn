import 'package:flutter/material.dart';
import 'package:serenessa_first_version/data/sos_repository.dart';
import 'package:serenessa_first_version/theme.dart'; // Assuming you have a file named app_colors.dart

class SosScreen extends StatefulWidget {
  final SOSRepository sosRepository = SOSRepository();

  SosScreen({Key? key}) : super(key: key);

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool _isSOSPressed = false; // For visual feedback during press
  bool _isSendingSOS = false; // To prevent multiple taps and show loading

  void _triggerSOS() async {
    if (_isSendingSOS) {
      print("SOS Button: Already sending, ignoring multiple tap.");
      return; // Prevent multiple simultaneous calls
    }

    setState(() {
      _isSOSPressed = true; // Visual feedback for immediate tap
      _isSendingSOS = true; // Start loading state
    });

    print("SOS Button Pressed - Attempting to Trigger SOS...");

    try {
      await widget.sosRepository.sendSOS();
      print("SOS triggered successfully!");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("SOS messages initiated! Please press send in each opened app."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5), // Keep it visible for a bit
        ),
      );

    } catch (e) {
      print("SOS Trigger Failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send SOS: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5), // Keep it visible for a bit
        ),
      );
    } finally {
      // Ensure these states are reset whether success or failure
      setState(() {
        _isSOSPressed = false;
        _isSendingSOS = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Are you in an emergency?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Press the button below and help will arrive shortly",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              // Disable tapping if already sending to prevent multiple launches
              onTap: _isSendingSOS ? null : _triggerSOS,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Change color if disabled/sending
                  color: _isSendingSOS ? Colors.grey : AppColors.primary,
                  border: _isSOSPressed
                      ? Border.all(
                    color: Colors.black.withOpacity(0.1),
                    width: 5, // Adjust width for the "inset" effect
                  )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSendingSOS
                      ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
                      : const Text(
                    "SOS",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Your Current Address",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Mirpurkhas, street # 32", // This might need to be dynamic
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}