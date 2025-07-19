import 'package:flutter/material.dart';
import 'package:serenessa_first_version/Screens/Fake_call_screen.dart';
import 'package:serenessa_first_version/Screens/SOS_screen.dart';
import 'package:serenessa_first_version/Screens/login_screen.dart';
import 'package:serenessa_first_version/Screens/signUp_screen.dart';
import 'package:serenessa_first_version/onboarding/onboarding_screen.dart';
import 'package:serenessa_first_version/presentation/quick_access_section.dart';
import 'screens/splash_screen.dart';
import 'screens/map_screen.dart';
import 'screens/Home.dart';
import 'package:serenessa_first_version/Screens/google_map_screen.dart';


class AppRoutes {

  static const String onboarding = '/onboarding'; // This is AppRoutes.onboarding
  static const String login = '/login';       // This is AppRoutes.signIn
  static const String home = '/home';           // This is AppRoutes.home
  static const String splash = '/splash';           // This is AppRoutes.home
  // Add other routes here


  static Map<String, WidgetBuilder> getRoutes() {
    var userName;
    return {
     splash: (context) => SplashScreen(),
       onboarding: (context) => OnboardingScreen(),
    //  '/map': (context) => GoogleMapScreen(),
      login: (context) => LoginScreen(),
      //'/signup': (context) => SignUpScreen() ,
     home: (context) => HomeScreen(userName: userName),
     // '/fakecall': (context) => FakeCallScreen(),
    };
  }
}

