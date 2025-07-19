import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serenessa_first_version/Screens/signUp_screen.dart';
import 'package:serenessa_first_version/theme.dart';
import 'Home.dart';
import '../services/auth_service.dart';
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
/*
  void _loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final user = await authService.signInWithEmail(email, password);

    if (user != null) {
      try {
        final uid = user.uid;
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = doc.data();

        if (data != null) {
          final firstName = data['firstName'] ?? '';
          final lastName = data['lastName'] ?? '';
          final fullName = ('$firstName $lastName').trim();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userName: fullName.isNotEmpty ? fullName : user.email ?? 'User'),
            ),
          );
        } else {
          _showError("No user data found.");
        }
      } catch (e) {
        print('Firestore error: $e');
        _showError("Failed to retrieve user data.");
      }
    } else {
      _showError("Email or password is incorrect");
    }
  }
*/


  void _loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final user = await authService.signInWithEmail(email, password);

    if (user != null) {
      // Extract name from email (you can replace with Firestore data later)
      final userName = email.split('@').first;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userName: userName)),
      );
    } else {
      _showError("Email or password is incorrect");
    }
  }

  /*
  void _loginWithGoogle() async {
    final user = await authService.signInWithGoogle();

    if (user != null) {
      try {
        final uid = user.uid;
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = doc.data();

        final firstName = data?['firstName'] ?? '';
        final lastName = data?['lastName'] ?? '';
        final fullName = ('$firstName $lastName').trim();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userName: fullName.isNotEmpty ? fullName : user.displayName ?? user.email ?? 'User'),
          ),
        );
      } catch (e) {
        print('Google Firestore error: $e');
        _showError("Failed to retrieve Google user data.");
      }
    } else {
      _showError("Google Sign-In failed");
    }
  }*/






  void _loginWithGoogle() async {
    final user = await authService.signInWithGoogle();

    if (user != null) {
      final userName = user.displayName ?? user.email?.split('@').first ?? 'User';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userName: userName)),
      );
    } else {
      _showError("Google Sign-In failed");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('assets/images/logo_circle.png'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Sign in to Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Your Password?",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              ),
              child: const Text("Sign in", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: Divider(thickness: 1, indent: 40, endIndent: 10)),
                Text("Or"),
                Expanded(child: Divider(thickness: 1, indent: 10, endIndent: 40)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                  onPressed: _loginWithGoogle,
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                  onPressed: () {}, // Facebook login can be added later
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}