import 'package:flutter/material.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createDrawerHeader(),
        /* _createDrawerItem(
            icon: Icons.calendar_today_outlined,
            text: 'Calendar',
            onTap: () {
              // Handle Calendar tap
              Navigator.pop(context); // Close the drawer
              print('Calendar tapped');
            },
          ),*/
          _createDrawerItem(
            icon: Icons.location_on_outlined,
            text: 'Address',
            onTap: () {
              // Handle Address tap
              Navigator.pop(context); // Close the drawer
              print('Address tapped');
            },
          ),
          _createDrawerItem(
            icon: Icons.group_outlined,
            text: 'Refer a Friend',
            onTap: () {
              // Handle Refer a Friend tap
              Navigator.pop(context); // Close the drawer
              print('Refer a Friend tapped');
            },
          ),
          _createDrawerItem(
            icon: Icons.support_agent_outlined,
            text: 'Help and Support',
            onTap: () {
              // Handle Support tap
              Navigator.pop(context); // Close the drawer
              print('Support tapped');
            },
          ),
          const Divider(),
          _createDrawerItem(
            icon: Icons.settings_outlined,
            text: 'Settings',
            onTap: () {
              // Handle Settings tap
              Navigator.pop(context); // Close the drawer
              print('Settings tapped');
            },
          ),
          _createDrawerItem(
            icon: Icons.logout_outlined,
            text: 'Logout',
            onTap: () {
              // Handle Logout tap
              Navigator.pop(context); // Close the drawer
              print('Logout tapped');
            },
          ),
        ],
      ),
    );
  }

  Widget _createDrawerHeader() {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
        color: Color(0xFF6A515E), // Assuming a similar purple color for the header
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 12.0,
            left: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  width: 80.0,
                  height: 80.0,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150/6A515E/FFFFFF/?Text=XYZ'), // Placeholder for user image
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'XYZ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'xyz@gmail.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(text),
      onTap: onTap,
    );
  }
}