import 'package:flutter/material.dart';
import 'package:growup_agro/splash_screen.dart';
import 'package:growup_agro/views/IntroPage.dart';
import 'package:growup_agro/views/Onboarding_Screen.dart';
import 'package:growup_agro/views/ProfilePage.dart';
import 'package:growup_agro/views/all_products_page.dart';
import 'package:growup_agro/views/all_projects.dart';
import 'package:growup_agro/views/all_properties.dart';
import 'package:growup_agro/views/desposit_page.dart';
import 'package:growup_agro/views/edit_profile_info.dart';
import 'package:growup_agro/views/investment_history.dart';
import 'package:growup_agro/views/investor_dashboard.dart';
import 'package:growup_agro/views/login.dart';
import 'package:growup_agro/views/long_duration.dart';
import 'package:growup_agro/views/my_projects.dart';
import 'package:growup_agro/views/register.dart';
import 'package:growup_agro/views/shariah.dart';
import 'package:growup_agro/views/short_duration.dart';
import 'package:growup_agro/views/wallet_history.dart';
import 'package:growup_agro/views/withdraw_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Splash screen is shown first
      // home: IntroPage(),
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/intro': (context) => const IntroPage(),
        'register': (context) => const MyRegister(),
        'login': (context) => const MyLogin(),

        //dashboard
        // '/dashboard': (context) => DashboardInvestor(),
        '/mainscreen': (context) => MainScreen(),


        //growup
        '/projects': (context) => const AllProjectsPage(),
        '/myprojects': (context) => const MyProjectsPage(),
        '/investmenthistory': (context) => const InvestmentHistoryPage(),

        '/products': (context) => const AllProductsPage(),
        '/properties': (context) => const AllPropertiesPage(),


        //Wallet
        '/wallet': (context) => const WalletHistoryPage(),
        '/deposit': (context) => const DepositPage(),

        '/withdraw': (context) => const WithdrawPage(),
        //Invoices
        '/myprofile': (context) => EditProfilePage(),
        '/profile': (context) => const InvestorProfilePage(),

        '/long_term': (context) => const LongProjectsPage(),
        '/short_term': (context) => const ShortProjectsPage(),
        '/shariah': (context) => const ShariahProjectsPage(),
        '/all_projects': (context) => const AllProjectsPage(),

        // '/long_term': (context) => const LongProjectsPage(),
        // '/short_term': (context) => const ShortProjectsPage(),
        // '/shariah': (context) => const ShariahProjectsPage(),
        // '/all_projects': (context) => const AllProjectsPage(),
      },

      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFEBFAEB),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Colors.grey[700],
            fontFamily: "FontMain",
          ),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF2E7D32), // Optional: set background color
          elevation: 0,
          centerTitle: true,
          // foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            // fontWeight: FontWeight.bold,
            //fontFamily: 'Fontappbar',
          ),
          iconTheme: IconThemeData(
            color: Colors.white, // for back button & icons
          ),
        ),
      ),

      //home: IntroPage(),
    );
  }
}
