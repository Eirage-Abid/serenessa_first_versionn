import 'package:flutter/material.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<String> contacts = []; // List to store emergency contacts

  void _addContact(String contact) {
    setState(() {
      contacts.add(contact);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Contacts")),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: "Enter contact number",
              contentPadding: EdgeInsets.all(10),
            ),
            keyboardType: TextInputType.phone,
            onSubmitted: _addContact,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(contacts[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      contacts.removeAt(index);
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
