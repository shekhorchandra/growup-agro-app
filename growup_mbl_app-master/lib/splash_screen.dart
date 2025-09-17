import 'dart:async';
import 'package:flutter/material.dart';
import 'package:growup_agro/views/Onboarding_Screen.dart';
import 'package:growup_agro/views/login.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'login.dart';
// import 'onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  late AnimationController _versionController;
  late Animation<double> _versionFade;
  late Animation<Offset> _versionSlide;

  String _version = '';

  @override
  void initState() {
    super.initState();

    // Logo fade-in animation
    _logoController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );
    _logoController.forward();

    // Version animation (fade and slide)
    _versionController = AnimationController(
      duration: const Duration(milliseconds: 3200),
      vsync: this,
    );
    _versionFade = CurvedAnimation(
      parent: _versionController,
      curve: Curves.easeInOut,
    );
    _versionSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _versionController,
      curve: Curves.easeOut,
    ));

    // Load version and animate version text
    _loadVersion();

    // Navigate after delay
    Timer(const Duration(seconds: 5), _navigateNext);
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = 'v${info.version}';
        });
        _versionController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _version = 'v1.0.0';
        });
        _versionController.forward();
      }
    }
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 2)); // show logo 2 sec

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!mounted) return;

    if (seenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyLogin()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }


  @override
  void dispose() {
    _logoController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Centered logo with fade animation
          Center(
            child: FadeTransition(
              opacity: _logoAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/GrowupLogo.png',
                    width: MediaQuery.of(context).size.width * 0.85,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Welcome to GrowUp Agrotech limited, Which is An Affiliate of The ROSA(NGO)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom animated version number
          if (_version.isNotEmpty)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _versionFade,
                child: SlideTransition(
                  position: _versionSlide,
                  child: Center(
                    child: Text(
                      _version,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
