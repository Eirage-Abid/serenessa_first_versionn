import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serenessa_first_version/theme.dart';
import 'package:serenessa_first_version/routes.dart'; // Import your routes file

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // User can be null, we will fetch it within _fetchDetails
  // final User? user = FirebaseAuth.instance.currentUser; // REMOVE THIS LINE

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final TextEditingController _safeZoneController = TextEditingController();

  List<String> emergencyContacts = [];
  List<String> safeZones = [];

  bool _isEditable = false;
  bool _isLoading = true;
  String _errorMessage = ''; // To store and display error messages

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    // Get the current user here, as it might change or be null on app resume
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in. Please log in again.';
        });
        // Optionally, navigate to login screen if user is not logged in
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
        // });
      }
      return; // Exit if no user
    }

    setState(() {
      _isLoading = true; // Start loading
      _errorMessage = ''; // Clear previous errors
    });
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        if (mounted) { // Ensure widget is still mounted before setting state
          setState(() {
            _nameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            // Ensure these are explicitly cast from dynamic to List<dynamic> before from()
            emergencyContacts = List<String>.from(data['emergencyContacts'] as List<dynamic>? ?? []);
            safeZones = List<String>.from(data['safeZones'] as List<dynamic>? ?? []);
          });
        }
      }
    } catch (e) {
      print("Error fetching details: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load details: $e";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load details: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // End loading
        });
      }
    }
  }

  Future<void> _saveDetails() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in. Cannot save details.')),
        );
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
        // });
      }
      return;
    }

    setState(() {
      _isLoading = true; // Show loading on button press
      _errorMessage = ''; // Clear previous errors
    });
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'emergencyContacts': emergencyContacts,
        'safeZones': safeZones,
      }, SetOptions(merge: true));
      if (mounted) {
        setState(() {
          _isEditable = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details saved successfully!')),
        );
      }
    } catch (e) {
      print("Error saving details: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to save details: $e";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save details: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading
        });
      }
    }
  }

  void _addEmergencyContact() {
    if (_emergencyPhoneController.text.trim().isNotEmpty) {
      setState(() {
        emergencyContacts.add(_emergencyPhoneController.text.trim());
        _emergencyPhoneController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency contact cannot be empty.')),
      );
    }
  }

  void _deleteEmergencyContact(int index) {
    setState(() {
      emergencyContacts.removeAt(index);
    });
  }

  void _addSafeZone() {
    if (_safeZoneController.text.trim().isNotEmpty) {
      setState(() {
        safeZones.add(_safeZoneController.text.trim());
        _safeZoneController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Safe Zone cannot be empty.')),
      );
    }
  }

  void _deleteSafeZone(int index) {
    setState(() {
      safeZones.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditable ? Icons.lock : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditable = !_isEditable;
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : _errorMessage.isNotEmpty
          ? Center( // Display error message if present
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetails, // Retry fetching details
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildInfoBox(
              label: 'Name',
              controller: _nameController,
              icon: Icons.person_outline,
              isEditable: _isEditable,
            ),
            const SizedBox(height: 10),
            _buildInfoBox(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email_outlined,
              isEditable: _isEditable,
            ),
            const SizedBox(height: 10),
            _buildInfoBox(
              label: 'Phone',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              isEditable: _isEditable,
            ),

            const SizedBox(height: 24),
            const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            for (int i = 0; i < emergencyContacts.length; i++)
              _buildListItemBox(
                value: emergencyContacts[i],
                icon: Icons.phone,
                label: 'Contact',
                onDelete: _isEditable ? () => _deleteEmergencyContact(i) : null,
              ),
            if (_isEditable)
              _buildAddEditField(
                hint: 'Add New Contact Number',
                controller: _emergencyPhoneController,
                onAdd: _addEmergencyContact,
                icon: Icons.phone_android,
              ),

            const SizedBox(height: 24),
            const Text('Safe Zones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            for (int i = 0; i < safeZones.length; i++)
              _buildListItemBox(
                value: safeZones[i],
                icon: Icons.location_on_outlined,
                label: 'Zone',
                onDelete: _isEditable ? () => _deleteSafeZone(i) : null,
              ),
            if (_isEditable)
              _buildAddEditField(
                hint: 'Add New Safe Zone',
                controller: _safeZoneController,
                onAdd: _addSafeZone,
                icon: Icons.map_outlined,
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || !_isEditable ? null : _saveDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                ),
                child: _isLoading
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

  // Reusable widget for Personal Information text fields
  Widget _buildInfoBox({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditable,
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
                  enabled: isEditable,
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

  // Reusable widget for displaying dynamic list items
  Widget _buildListItemBox({
    required String value,
    required IconData icon,
    required String label,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  // Reusable widget for adding new items
  Widget _buildAddEditField({
    required String hint,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

/**import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart'; // Not directly used in widget
import 'package:serenessa_first_version/theme.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final TextEditingController _safeZoneController = TextEditingController(); // For adding new safe zones

  List<String> emergencyContacts = [];
  List<String> safeZones = []; // Assuming safeZones are still simple strings for now based on your code

  bool _isEditable = false;
  bool _isLoading = true; // Added loading state for data fetching

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      final doc = await _firestore.collection('users').doc(user?.uid).get();
      final data = doc.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        emergencyContacts = List<String>.from(data['emergencyContacts'] ?? []);
        safeZones = List<String>.from(data['safeZones'] ?? []);
      }
    } catch (e) {
      print("Error fetching details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load details: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  Future<void> _saveDetails() async {
    setState(() {
      _isLoading = true; // Show loading on button press
    });
    try {
      await _firestore.collection('users').doc(user?.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'emergencyContacts': emergencyContacts,
        'safeZones': safeZones,
      }, SetOptions(merge: true));
      setState(() {
        _isEditable = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details saved successfully!')),
      );
    } catch (e) {
      print("Error saving details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save details: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading
      });
    }
  }

  void _addEmergencyContact() {
    if (_emergencyPhoneController.text.trim().isNotEmpty) {
      setState(() {
        emergencyContacts.add(_emergencyPhoneController.text.trim());
        _emergencyPhoneController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency contact cannot be empty.')),
      );
    }
  }

  void _deleteEmergencyContact(int index) {
    setState(() {
      emergencyContacts.removeAt(index);
    });
  }

  void _addSafeZone() {
    if (_safeZoneController.text.trim().isNotEmpty) {
      setState(() {
        safeZones.add(_safeZoneController.text.trim());
        _safeZoneController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Safe Zone cannot be empty.')),
      );
    }
  }

  void _deleteSafeZone(int index) {
    setState(() {
      safeZones.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditable ? Icons.lock : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditable = !_isEditable;
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildInfoBox(
              label: 'Name',
              controller: _nameController,
              icon: Icons.person_outline,
              isEditable: _isEditable,
            ),
            const SizedBox(height: 10),
            _buildInfoBox(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email_outlined,
              isEditable: _isEditable,
            ),
            const SizedBox(height: 10),
            _buildInfoBox(
              label: 'Phone',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              isEditable: _isEditable,
            ),

            const SizedBox(height: 24),
            const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            // Display existing emergency contacts
            for (int i = 0; i < emergencyContacts.length; i++)
              _buildListItemBox(
                value: emergencyContacts[i],
                icon: Icons.phone,
                label: 'Contact',
                onDelete: _isEditable ? () => _deleteEmergencyContact(i) : null,
              ),
            // Add new emergency contact field
            if (_isEditable)
              _buildAddEditField(
                hint: 'Add New Contact Number',
                controller: _emergencyPhoneController,
                onAdd: _addEmergencyContact,
                icon: Icons.phone_android, // Specific icon for phone number
              ),

            const SizedBox(height: 24),
            const Text('Safe Zones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            // Display existing safe zones
            for (int i = 0; i < safeZones.length; i++)
              _buildListItemBox(
                value: safeZones[i],
                icon: Icons.location_on_outlined,
                label: 'Zone',
                onDelete: _isEditable ? () => _deleteSafeZone(i) : null,
              ),
            // Add new safe zone field
            if (_isEditable)
              _buildAddEditField(
                hint: 'Add New Safe Zone',
                controller: _safeZoneController,
                onAdd: _addSafeZone,
                icon: Icons.map_outlined, // Specific icon for safe zone
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || !_isEditable ? null : _saveDetails, // Disable button if loading or not editable
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3, // Added shadow for consistency
                ),
                child: _isLoading
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

  // Reusable widget for Personal Information text fields (like in EditProfileScreen)
  Widget _buildInfoBox({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditable, // Pass editability here
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
                  enabled: isEditable, // Control editability here
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

  // Reusable widget for displaying dynamic list items (Emergency Contacts, Safe Zones)
  Widget _buildListItemBox({
    required String value,
    required IconData icon,
    required String label,
    VoidCallback? onDelete, // Make onDelete nullable
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                const SizedBox(height: 2), // Small spacing
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          if (onDelete != null) // Only show delete button if onDelete is provided (i.e., if editable)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  // Reusable widget for adding new items (Emergency Contacts, Safe Zones)
  Widget _buildAddEditField({
    required String hint,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10), // Add some top margin
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjust padding
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none, // Remove border
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

*/

