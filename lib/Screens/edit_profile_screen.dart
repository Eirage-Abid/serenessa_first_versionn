import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  String _safeZone = '';
  String? _profileImageUrl; // This will store the URL from Firebase Storage
  File? _imageFile; // This will store the newly picked image file for upload

  bool _isLoading = true; // Initialize to true

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _nameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _emergencyPhoneController.text = data['emergencyPhone'] ?? '';
            _safeZone = data['safeZone'] ?? '';
            _profileImageUrl = data['profileImage']; // Load existing profile image URL
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
        // Optionally show a snackbar or error message to the user
      } finally {
        // IMPORTANT: Set isLoading to false regardless of success or failure
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // If user is null (not logged in), we should also stop loading
      setState(() {
        _isLoading = false;
      });
      // Optionally navigate to login or show a message
    }
  }

  Future<void> _saveChanges() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _isLoading = true; // Show loading indicator while saving
      });
      String? uploadedImageUrl = _profileImageUrl; // Start with current URL
      try {
        if (_imageFile != null) {
          final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
          await storageRef.putFile(_imageFile!);
          uploadedImageUrl = await storageRef.getDownloadURL();
        }

        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'emergencyPhone': _emergencyPhoneController.text,
          'safeZone': _safeZone,
          'profileImage': uploadedImageUrl, // Save the potentially new URL
        }, SetOptions(merge: true));

        setState(() {
          _profileImageUrl = uploadedImageUrl; // Update local URL after successful upload
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      } catch (e) {
        print("Error saving changes: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator after saving (or error)
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        // No need to set _profileImageUrl here, as _imageFile will be used for display
        // and then uploaded on _saveChanges
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null // Use newly picked image first
                        ? FileImage(_imageFile!)
                        : (_profileImageUrl != null // Then use existing network image
                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                        : null),
                    child: _imageFile == null && _profileImageUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildInfoBox(label: 'Name', controller: _nameController, icon: Icons.person_outline),
            const SizedBox(height: 10),
            _buildInfoBox(label: 'Email', controller: _emailController, icon: Icons.email_outlined),
            const SizedBox(height: 10),
            _buildInfoBox(label: 'Phone', controller: _phoneController, icon: Icons.phone_outlined),
            const SizedBox(height: 24),
            const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            // Ensure this reflects the _emergencyPhoneController.text
            _buildEmergencyContactBox(
              name: 'Baba', // This name 'Baba' seems hardcoded. You might want to load it too.
              phone: _emergencyPhoneController.text,
            ),
            const SizedBox(height: 24),
            const Text('Safety Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildSafetyPreferenceBox(value: _safeZone),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges, // Disable button while loading/saving
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                child: _isLoading // Show saving indicator on button
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Your _buildInfoBox, _buildEmergencyContactBox, _buildSafetyPreferenceBox methods remain the same)
  Widget _buildInfoBox({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactBox({required String name, required String phone}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.phone, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Phone: $phone', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyPreferenceBox({required String value}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Safe Zone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(value, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}