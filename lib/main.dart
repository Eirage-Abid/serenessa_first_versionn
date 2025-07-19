import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:serenessa_first_version/routes.dart'; // Your routes file
import 'package:serenessa_first_version/firebase_options.dart'; // Your Firebase options file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This Future will hold the determined initial route name
  late Future<String> _initialRouteFuture;

  @override
  void initState() {
    super.initState();
    _initialRouteFuture = _determineInitialRoute();
  }

  Future<String> _determineInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

    if (!hasCompletedOnboarding) {
      // If onboarding hasn't been completed, start there
      return AppRoutes.onboarding; // Use the named route from your routes.dart
    } else {
      // If onboarding IS completed, check Firebase Auth state
      final user = await FirebaseAuth.instance.authStateChanges().first;

      if (user == null) {
        // No user logged in, go to sign-in screen
        return AppRoutes.login; // Use the named route
      } else {
        // User is logged in, go to home screen
        return AppRoutes.home; // Use the named route
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serenessa',
      // Use FutureBuilder to wait for the initial route to be determined
      home: FutureBuilder<String>(
        future: _initialRouteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Once the future is complete, navigate to the determined route
            // We use a Navigator to push the replacement route.
            // This is a common pattern for initial routing with named routes.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(snapshot.data!);
            });
            // Show a temporary loading screen while the navigation happens
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            // Show a loading indicator while the initial route is being determined
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      routes: AppRoutes.getRoutes(), // Your defined routes
    );
  }
}