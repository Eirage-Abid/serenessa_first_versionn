import 'package:flutter/material.dart';
import 'package:serenessa_first_version/theme.dart'; // Assuming you have AppColors here
import '../presentation/location_history_model.dart'; // Import your model

class LocationHistoryScreen extends StatefulWidget {
  @override
  _LocationHistoryScreenState createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
  // Sample data to populate the list
  final List<LocationHistoryEntry> historyEntries = [
    LocationHistoryEntry(
      contactName: 'Mom',
      isOnline: true,
      location: '123 Park Street, New York, NY 10001',
      date: 'Aug 7, 2023',
      time: '3:45 PM',
      timeAgo: '2 hours ago',
    ),
    LocationHistoryEntry(
      contactName: 'Priya Sharma',
      isOnline: false,
      location: 'Central Park West, New York, NY 10024',
      date: 'Aug 6, 2023',
      time: '7:30 PM',
      timeAgo: 'Yesterday',
    ),
    LocationHistoryEntry(
      contactName: 'Emergency Contact',
      isOnline: false,
      location: 'Times Square, New York, NY 10036',
      date: 'Aug 5, 2023',
      time: '9:15 AM',
      timeAgo: '2 days ago',
    ),
    LocationHistoryEntry(
      contactName: 'Sister',
      isOnline: false,
      location: 'Broadway, New York, NY 10001',
      date: 'Aug 4, 2023',
      time: '2:20 PM',
      timeAgo: '3 days ago',
    ),
    LocationHistoryEntry(
      contactName: 'Best Friend',
      isOnline: false,
      location: 'Fifth Avenue, New York, NY 10022',
      date: 'Aug 3, 2023',
      time: '11:45 AM',
      timeAgo: '4 days ago',
    ),
    // Add more entries as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      appBar: AppBar(
        backgroundColor: AppColors.primary, // Make app bar background transparent
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
        title: Text(
          'Location History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
     /*   actions: [
          IconButton(
            icon: Icon(Icons.sort, color: Colors.black), // Using sort icon for the filter/menu
            onPressed: () {
              // Handle filter/sort action
            },
          ),
        ],

      */
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: historyEntries.length,
        itemBuilder: (context, index) {
          final entry = historyEntries[index];
          return LocationHistoryCard(entry: entry);
        },
      ),
    );
  }
}

class LocationHistoryCard extends StatelessWidget {
  final LocationHistoryEntry entry;

  const LocationHistoryCard({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 0, // No shadow for the cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Rounded corners
      ),
      color: Colors.white, // White background for the card
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      entry.contactName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: entry.isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Text(
                  entry.timeAgo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    entry.location,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis, // Handle long location names
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                SizedBox(width: 5),
                Text(
                  '${entry.date} · ${entry.time}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  // Handle "View Location" action
                  print('View Location for ${entry.contactName}');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary), // Use your primary color for border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: Text(
                  'View Location',
                  style: TextStyle(
                    color: AppColors.primary, // Use your primary color for text
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}