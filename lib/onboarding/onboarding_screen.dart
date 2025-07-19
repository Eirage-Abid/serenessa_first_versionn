import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:serenessa_first_version/theme.dart';
import '../onboarding/onboarding_page.dart';
import '../presentation/custom_button.dart';
import '../routes.dart'; // Import your routes file

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/serenessa_community.png", // Ensure this path is correct
      "title": "Your Personalized Reading Experience",
      "description":
      "Customize your reading journey with intuitive features designed just for you."
    },
    {
      "image": "assets/images/serenessa_call.png", // Ensure this path is correct
      "title": "Bookmark & Highlight",
      "description":
      "Easily mark important pages and highlight key text for quick reference."
    },
    {
      "image": "assets/images/serenessa_verification.png", // Ensure this path is correct
      "title": "Download for Offline Access",
      "description":
      "Save your favorite books and enjoy reading without an internet connection."
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true); // Set the flag
    // Navigate to the sign-in screen using the named route
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _nextPage() {
    if (_currentPage == onboardingData.length - 1) {
      // If it's the last page, complete onboarding
      _completeOnboarding();
    } else {
      // Move to the next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // _navigateToLogin is now redundant with _completeOnboarding, but if you want
  // a skip that *doesn't* mark as completed for some reason, you'd keep it separate.
  // For standard behavior, skip should also mark as completed.
  void _navigateToLoginFromSkip() {
    _completeOnboarding(); // Mark onboarding complete even if skipped
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) => OnboardingPage(
                    image: onboardingData[index]["image"]!,
                    title: onboardingData[index]["title"]!,
                    description: onboardingData[index]["description"]!,
                    currentPageIndex: _currentPage,
                    totalPages: onboardingData.length,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _currentPage == onboardingData.length - 1
                        ? "Continue"
                        : "Next",
                    onPressed: _nextPage,
                  ),
                ),
              ),
            ],
          ),

          // Skip Button at Top Right
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: _navigateToLoginFromSkip, // Use the new skip method
              child: Text(
                "Skip",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}