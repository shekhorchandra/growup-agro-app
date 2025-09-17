import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:growup_agro/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.grass,
      "title": "The Future of Farming, Today.",
      "subtitle":
      "Join a community of modern farmers. Get insights, manage your crops, and grow your business.",
      "image": "assets/images/futurefram.jpg"
    },
    {
      "icon": Icons.show_chart,
      "title": "Invest in Agro-Projects",
      "subtitle":
      "Fund promising agricultural projects and become a trusted partner in their success, all in a few taps.",
      "image": "assets/images/animal.jpg"
    },
    {
      "icon": Icons.home,
      "title": "Own Your Farmland",
      "subtitle":
      "Buy or invest in agricultural land. Build your dream farm and move towards a sustainable future.",
      "image": "assets/images/fram.jpg"
    },
    {
      "icon": Icons.shopping_cart,
      "title": "Shop for Agri-essentials",
      "subtitle":
      "From seeds and fertilizers to modern machinery, get all your farming needs from our trusted marketplace.",
      "image": "assets/images/agriessn.jpg"
    },
  ];

  void _onButtonTap() async {
    if (currentPage == pages.length - 1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyLogin()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // PageView with backgrounds
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => currentPage = index);
            },
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    pages[index]["image"]!,
                    fit: BoxFit.cover,
                  ),
                  // 👇 Add BackdropFilter for blur
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // little blur
                    child: Container(
                      color: Colors.black.withOpacity(0.3), // keeps dark overlay
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Card in center
                  Align(
                    alignment: const Alignment(0, -0.1),
                    child: Card(
                      color: Colors.black.withOpacity(0.65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.04,
                          horizontal: screenWidth * 0.06,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start, // 👈 left aligned
                          children: [
                            Icon(
                              pages[index]["icon"],
                              color: Colors.white,
                              size: screenWidth * 0.15,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              pages[index]["title"]!,
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Text(
                              pages[index]["subtitle"]!,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Skip button
          Positioned(
            top: screenHeight * 0.06,
            right: screenWidth * 0.05,
            child: TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seenOnboarding', true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyLogin()),
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: screenHeight * 0.08,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                      width: currentPage == index ? screenWidth * 0.06 : screenWidth * 0.025,
                      height: screenHeight * 0.01,
                      decoration: BoxDecoration(
                        color: currentPage == index ? Colors.green : Colors.white54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Next/Get Started button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.3,
                      vertical: screenHeight * 0.018,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _onButtonTap,
                  child: Text(
                    currentPage == pages.length - 1 ? "Get Started" : "Next",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
