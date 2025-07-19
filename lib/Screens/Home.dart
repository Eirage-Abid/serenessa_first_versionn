import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serenessa_first_version/Screens/edit_details_screen.dart';
import 'package:serenessa_first_version/Screens/edit_profile_screen.dart';
import 'package:serenessa_first_version/Screens/google_map_screen.dart';
import 'package:serenessa_first_version/Screens/location_history_screen.dart';
import 'package:serenessa_first_version/Screens/map_screen.dart';
import 'package:serenessa_first_version/presentation/navigationbar.dart';
import 'package:serenessa_first_version/Screens/SOS_screen.dart';
import '../presentation/quick_access_section.dart';
import '../presentation/navigation_drawer.dart';
import '../presentation/grid_buttons_screen.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  final String userName; // NEW
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({Key? key, required this.userName}) : super(key: key); // NEW

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _currentIndexx = 0;
  late Timer _timer;

  Position? _currentPosition;
  bool _isLocating = false;

  final List<Map<String, String>> _reminderTips = [
    {
      "image": "assets/images/tip1.png",
      "text": "Always share your live location with a trusted friend.",
    },
    {
      "image": "assets/images/tip2.png",
      "text": "Avoid dark or isolated areas when walking alone at night.",
    },
    {
      "image": "assets/images/tip3.png",
      "text": "Use emergency buttons in unsafe situations.",
    },
  ];

  void _onTabChanged(int indexx) {
    setState(() {
      _currentIndexx = indexx;
    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer timer) {
      if (_currentIndex < _reminderTips.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLocating = true);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      setState(() => _isLocating = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions denied.')),
        );
        setState(() => _isLocating = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions permanently denied.')),
      );
      setState(() => _isLocating = false);
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _launchMaps(String query) async {
    if (_currentPosition == null) {
      await _determinePosition();
      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get your location.')),
        );
        return;
      }
    }

    final String lat = _currentPosition!.latitude.toString();
    final String long = _currentPosition!.longitude.toString();
    final Uri uri = Uri.parse('https://www.google.com/maps/search/$query/@$lat,$long,14z');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch Maps for $query')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Widget _getBody() {
    switch (_currentIndexx) {
      case 0:
        return _buildMainHomeScreenContent();
      case 1:
        return const GoogleMapScreen();
      case 2:
        return SosScreen();
      case 3:
        return const DetailsScreen();
      case 4:
        return LocationHistoryScreen();
      default:
        return _buildMainHomeScreenContent();
    }
  }

  Widget _buildMainHomeScreenContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 230),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Stack(
                              children: [
                                Container(
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDFBFF),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.20),
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        offset: const Offset(2, 3),
                                      ),
                                    ],
                                  ),
                                  child: PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentIndex = index;
                                      });
                                    },
                                    itemCount: _reminderTips.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              _reminderTips[index]['image']!,
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                _reminderTips[index]['text']!,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF4B3B4E),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GridButtonCards(parentContext: context),
                      const SizedBox(height: 20),
                      HomeCardsSection(
                        onPoliceTap: () => _launchMaps("police stations near me"),
                        onHospitalTap: () => _launchMaps("hospitals near me"),
                        onEmergencyContactsTap: () {},
                        isLocating: _isLocating,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "More Features Coming Soon...",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              // Top menu + greetings
              Positioned(
                top: 40,
                left: 16,
                child: Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () => widget._scaffoldKey.currentState?.openDrawer(),
                      child: const Icon(Icons.menu, color: Colors.white, size: 28),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
                      child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.search, color: Colors.white, size: 28),
                    const SizedBox(width: 16),
                    Stack(
                      children: [
                        const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                        Positioned(
                          right: 3,
                          top: 3,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.purpleAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 👇 Greet user with dynamic name
              Positioned(
                top: 90,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hello,",
                      style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      widget.userName,
                      style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You're currently in your Safe/\nUnsafe Zone",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldKey,
      backgroundColor: const Color(0xFF58465B),
      body: Stack(children: [_getBody()]),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: NavigationBarView(
            currentIndexx: _currentIndexx,
            onTabChanged: _onTabChanged,
          ),
        ),
      ),
      drawer: const AppNavigationDrawer(),
    );
  }
}
