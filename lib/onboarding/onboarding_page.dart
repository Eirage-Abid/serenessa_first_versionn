import 'package:flutter/material.dart';
import 'package:serenessa_first_version/theme.dart'; // Assuming this file exists and contains AppColors

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final int currentPageIndex; // Added to indicate the current page for the dots
  final int totalPages;      // Added to know the total number of pages for the dots

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.currentPageIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Container( // Use Container instead of Column directly for overall background
      color: AppColors.white, // Set the whole background to white
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 20), // Add top padding for status bar
          Expanded(
            flex: 4, // Give more space to the illustration
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20), // Add horizontal padding
              child: Image.asset(
                image,
                fit: BoxFit.contain, // Adjust fit as needed
              ),
            ),
          ),
          Expanded(
            flex: 2, // Allocate space for text and dots
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary, // Using your primary color for title
                      fontSize: 28, // Increase font size for prominence
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700], // A darker grey for better readability
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 40), // Space before the dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      totalPages,
                          (index) => buildDot(index, context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: currentPageIndex == index ? 12 : 8, // Larger dot for current page
      height: 8,
      decoration: BoxDecoration(
        color: currentPageIndex == index ? AppColors.primary : Colors.grey[300], // Highlight current dot
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}