import 'package:flutter/material.dart';

class LocationHistoryEntry {
  final String contactName;
  final bool isOnline; // Representing the green/grey dot
  final String location;
  final String date;
  final String time;
  final String timeAgo; // e.g., "2 hours ago", "Yesterday"

  LocationHistoryEntry({
    required this.contactName,
    this.isOnline = false, // Default to false (grey dot)
    required this.location,
    required this.date,
    required this.time,
    required this.timeAgo,
  });
}