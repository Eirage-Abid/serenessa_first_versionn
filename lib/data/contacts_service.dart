import 'package:shared_preferences/shared_preferences.dart';

class ContactsService {
  Future<void> addContact(String contact) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> contacts = prefs.getStringList('contacts') ?? [];
    contacts.add(contact);
    await prefs.setStringList('contacts', contacts);
  }

  Future<List<String>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('contacts') ?? [];
  }

  Future<void> removeContact(String contact) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> contacts = prefs.getStringList('contacts') ?? [];
    contacts.remove(contact);
    await prefs.setStringList('contacts', contacts);
  }
}
