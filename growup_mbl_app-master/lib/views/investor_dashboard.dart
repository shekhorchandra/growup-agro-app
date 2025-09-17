import 'dart:convert';
import 'dart:ui';
// import 'package:carousel_slider/carousel_slider.dart' show CarouselSlider, CarouselOptions;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:growup_agro/models/shariah_project_model.dart';
import 'package:growup_agro/models/slider_model.dart';
import 'package:growup_agro/models/wallet_history_model.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:growup_agro/views/NotificationPage.dart';
import 'package:growup_agro/views/all_projects.dart';
import 'package:growup_agro/views/all_properties.dart';
import 'package:growup_agro/views/desposit_page.dart';
import 'package:growup_agro/views/investment_history.dart';
import 'package:growup_agro/views/invoice_capital_return.dart';
import 'package:growup_agro/views/invoice_growup.dart';
import 'package:growup_agro/views/invoice_recharge.dart';
import 'package:growup_agro/views/invoice_roi.dart';
import 'package:growup_agro/views/my_orders_page.dart';
import 'package:growup_agro/views/project_Descriotion_page.dart';
import 'package:growup_agro/views/project_certificate_page.dart';
// import '../../../growup_agro/lib/views/desposit_page.dart';
import 'package:growup_agro/views/recharge_page.dart';
import 'package:growup_agro/views/residencial_city_page.dart';
import 'package:growup_agro/views/shariah.dart';
import 'package:growup_agro/views/short_duration.dart';
import 'package:growup_agro/views/tax_certificate.dart';
import 'package:growup_agro/views/todays_income_dialog.dart';
import 'package:growup_agro/views/total_income_dialog.dart';
import 'package:growup_agro/views/upcoming_projects.dart';
import 'package:growup_agro/views/wallet_balance_dialog.dart';
import 'package:growup_agro/views/wallet_history.dart';
import 'package:growup_agro/views/withdraw_page.dart';
import 'package:growup_agro/widgets/bottom_nav_bar.dart';
import 'package:growup_agro/widgets/webview_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/all_properties.model.dart';
import 'IntroPage.dart';
import 'all_products_page.dart';
import 'completed_projects.dart';
import 'total_investment_dialog.dart' hide WalletHistoryDialog;
import 'eco_city.dart';
import 'healthcare.dart';
import 'hitech_city.dart';
import 'long_duration.dart'; // For SystemNavigator.pop()
import 'package:intl/intl.dart';

import 'my_growup_projects_dialog.dart';
import 'my_projects.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardInvestor(),
    );
  }
}

class DashboardInvestor extends StatefulWidget {
  const DashboardInvestor({super.key});

  @override
  State<DashboardInvestor> createState() => _DashboardInvestorState();
}

class _DashboardInvestorState extends State<DashboardInvestor> {

  // slider picture start
  final List<String> imageUrls = [
    'https://admin-growup.onebitstore.site/storage/uploads/slider-image/685fd4a480ada.png',
    'https://admin-growup.onebitstore.site/storage/uploads/slider-image/685fd3aedd5c0.png',
    'https://admin-growup.onebitstore.site/storage/uploads/slider-image/685fd3e7a2ba4.png',
    'https://admin-growup.onebitstore.site/storage/uploads/slider-image/685fd3f67e26c.png',
  ];
  //slider picture end
  int _selectedIndex = 0;
  double totalIncome = 0.0;
  double todaysIncome = 0.0;
  int totalProjects = 0;
  String totalwallet_balance = '0';
  String totalInvestment = '0';
  String _walletBalance = '0';
  int _loyaltyPoints = 78;
  bool _showAllCards = false; // Add this inside your State class
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _searchKey = GlobalKey();

  // List<SliderItem> sliders = [];
  // bool isLoading = true;

  List<Map<String, dynamic>> _walletTransactions = [];
  late Future<Map<String, dynamic>> _profileFuture;

  final List<Widget> _pages = [
    // MenuPage(),       // index 0
    // GrowupPage(),     // index 1
    // PropertyPage(),   // index 2
    // TradingPage(),    // index 3
    // WebTabPage(),     // index 4 <-- this shows your WebView
  ];

  @override
  void initState() {
    super.initState();

    // Initialize immediately to avoid LateInitializationError
    _profileFuture = getInvestorProfileFromPrefs();

    // Then refresh data in background
    fetchAndSaveInvestorProfile().then((_) {
      setState(() {
        _profileFuture = getInvestorProfileFromPrefs(); // Load fresh profile
      });
    });

    fetchWalletBalance().then((_) {
      _loadDashboardData();
    });

    fetchWalletHistory().then((list) {
      setState(() {
        _walletTransactions = list
            .map(
              (e) => {
                'type': e.type,
                'created_at': e.createdAt,
                'amount': e.amount,
                'status': e.status ?? 'N/A',
                'trx_id': e.trxId,
              },
            )
            .toList();
      });
    });
  }

  // slider api start

  // Future<void> fetchSliderImages() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token');
  //
  //     if (token == null) {
  //       print("Token is null");
  //       setState(() => isLoading = false);
  //       return;
  //     }
  //
  //     final response = await http.get(
  //       Uri.parse('https://admin-growup.onebitstore.site/api/investor/slider'),
  //       headers: {'Authorization': 'Bearer $token'},
  //     );
  //
  //     print("Slider API response code: ${response.statusCode}");
  //
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> data;
  //       try {
  //         data = json.decode(response.body);
  //       } catch (e) {
  //         print("JSON decoding error: $e");
  //         setState(() => isLoading = false);
  //         return;
  //       }
  //
  //       if (data['sliders'] == null) {
  //         print("No 'sliders' key in API response!");
  //         setState(() => isLoading = false);
  //         return;
  //       }
  //
  //       final List<dynamic> sliderData = data['sliders'];
  //       print("Slider count: ${sliderData.length}");
  //
  //       for (var item in sliderData) {
  //         print("Slider image: ${item['image_url']}");
  //       }
  //
  //       setState(() {
  //         sliders = sliderData
  //             .where((item) => item['image_url'] != null)
  //             .map((item) => SliderItem.fromJson(item))
  //             .toList();
  //         isLoading = false;
  //       });
  //     } else {
  //       print("Slider load failed: ${response.statusCode}");
  //       setState(() => isLoading = false);
  //     }
  //   } catch (e) {
  //     print("Slider fetch error: $e");
  //     setState(() => isLoading = false);
  //   }
  // }

  //slider api end

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  //wallet balance

  //
  Future<void> fetchAndSaveInvestorProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    debugPrint('Token: $token');
    final investorCode = prefs.getString('investor_code') ?? '';

    // final response = await http.get(
    //   Uri.parse(
    //     'https://admin-growup.onebitstore.site/api/investor/profile?investor_code=$investorCode',
    //   ),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );
    final url = Uri.parse(ApiConstants.investorProfile(investorCode));
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );


    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final data = jsonData['data']['investor'];

      await prefs.setString('investor_name', data['name'] ?? '');
      await prefs.setString('investor_email', data['email'] ?? '');
      await prefs.setString('investor_phone', data['phone'] ?? '');
      await prefs.setString('investor_code', data['investor_code'] ?? '');
      await prefs.setString('investor_image', data['image'] ?? '');

      prefs.setString(
        'wallet_balance',
        jsonData['data']['wallet_balance'].toString(),
      );
      //prefs.setString('total_transation', jsonData['data']['total_transation'].toString());
      prefs.setString(
        'total_investment',
        jsonData['data']['total_investment'].toString(),
      );
      prefs.setString(
        'total_income',
        jsonData['data']['total_income'].toString(),
      );
      prefs.setString(
        'todays_income',
        jsonData['data']['todays_income'].toString(),
      );
      prefs.setString(
        'total_projects',
        jsonData['data']['total_projects'].toString(),
      );
    } else {
      debugPrint('Failed to fetch profile: ${response.statusCode}');
    }
  }

  //wallet balance
  Future<void> fetchWalletBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final investorCode = prefs.getString('investor_code') ?? '';

    try {
      // final response = await http.get(
      //   Uri.parse(
      //     'https://admin-growup.onebitstore.site/api/investor/profile?investor_code=$investorCode',
      //   ),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //     'Accept': 'application/json',
      //   },
      // );
      final url = Uri.parse(ApiConstants.investorProfile(investorCode));
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final balanceRaw =
            jsonData['data']['investor']['wallet']['balance'] ?? '0';
        final parsedBalance = double.tryParse(balanceRaw.toString()) ?? 0.0;

        // Save raw value (without formatting) for calculations if needed
        await prefs.setString('wallet_balance_raw', parsedBalance.toString());

        final formattedBalance = NumberFormat('#,##0.00').format(parsedBalance);

        // Save formatted version for UI
        await prefs.setString('wallet_balance', formattedBalance);

        if (mounted) {
          setState(() {
            _walletBalance = formattedBalance;
          });
        }
      } else {
        print(
          "Failed to fetch wallet balance, status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error fetching wallet balance: $e");
    }
  }

  //counter
  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      totalwallet_balance = prefs.getString('wallet_balance') ?? '0';
      totalInvestment = prefs.getString('total_investment') ?? '0';
      totalIncome =
          double.tryParse(prefs.getString('total_income') ?? '0') ?? 0.0;
      todaysIncome =
          double.tryParse(prefs.getString('todays_income') ?? '0') ?? 0.0;
      totalProjects =
          int.tryParse(prefs.getString('total_projects') ?? '0') ?? 0;
      print(
        'Updated: $totalwallet_balance, $totalInvestment, $totalIncome, $todaysIncome, $totalProjects',
      );
    });
  }

  //fetchUserName() function
  Future<Map<String, dynamic>> getInvestorProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'name': prefs.getString('investor_name') ?? 'N/A',
      'email': prefs.getString('investor_email') ?? 'N/A',
      'phone': prefs.getString('investor_phone') ?? 'N/A',
      'code': prefs.getString('investor_code') ?? 'N/A', // fix here
      'image': prefs.getString('investor_image') ?? '',
      // 'walletbalance': prefs.getString('wallet_balance') ?? 'N/A',
      // "totalinvestment": prefs.getString('total_investment') ?? 'N/A',
      // "totalIncome": prefs.getString('total_income') ?? 'N/A',
      // "todaysIncome": prefs.getString('todays_income') ?? 'N/A',
      // "totalProjects": prefs.getString('total_projects') ?? 'N/A',
    };
  }

  Future<AllPropertiesResponse> fetchProperties() async {
    final response = await http.get(
      Uri.parse("https://admin-growup.onebitstore.site/api/properties"),
    );

    if (response.statusCode == 200) {
      return AllPropertiesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load properties");
    }
  }


  // logout start
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final investorCode = prefs.getString('investor_code') ?? '';

    // final url = Uri.parse(
    //   'https://admin-growup.onebitstore.site/api/investor/logout',
    // );

    try {
      final url = Uri.parse(ApiConstants.logout);
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {'investor_code': investorCode},
      );


      if (response.statusCode == 200) {
        // Logout successful
        await prefs.clear();

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, 'login');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout successful'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed. Please try again'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
  //logout end

  //transaction
  Future<List<WalletHistoryModel>> fetchWalletHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final investorCode = prefs.getString('investor_code');

    // final url = Uri.parse(
    //   'https://admin-growup.onebitstore.site/api/wallet-history?investor_code=$investorCode',
    // );
    //
    // final response = await http.get(
    //   url,
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );
    final url = Uri.parse(ApiConstants.walletHistory(investorCode!));
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((item) => WalletHistoryModel.fromJson(item))
            .toList();
      } else {
        throw Exception('No wallet history found');
      }
    } else {
      throw Exception('Failed to load wallet history');
    }
  }

  // transaction end

  //Projects you may invest start
  Future<List<ShariahProject>> fetchShariahProjects() async {
    // final url = Uri.parse(
    //   'https://admin-growup.onebitstore.site/api/all-projects',
    // );
    final url = Uri.parse(ApiConstants.allProjects());
    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No auth token found. Please login again.');
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['projects'] == null ||
            jsonData['projects']['Live Projects'] == null) {
          throw Exception('Live Projects section missing in API response.');
        }

        final List<dynamic> shariahProjects =
            jsonData['projects']['Live Projects'];

        return shariahProjects
            .map((json) => ShariahProject.fromJson(json))
            .take(3)
            .toList();
      } else {
        throw Exception(
          'Failed to load Live Projects - status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception in fetchLive Projects(): $e');
      throw Exception('Failed to load Live Projects');
    }
  }
  //Projects you may invest end



  // by default back button
  Future<void> _logoutAndGoToIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const IntroPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // by default back button
    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          await _logoutAndGoToIntro();
          return false; // Prevents default pop
        }
        return false; // Cancel back navigation
      },
      child: Scaffold(
        //left drawer fetch data from api
        drawer: Drawer(
          backgroundColor: const Color(0xFFFFFFFF),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error loading profile"));
              } else {
                final profile = snapshot.data!;
                return Container(
                  color: const Color(0xFFFFFFFF),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // DrawerHeader(
                      //   decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
                      //   margin: EdgeInsets.zero,
                      //   padding: const EdgeInsets.all(16),
                      //   child: Row(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       // Avatar on the left
                      //       CircleAvatar(
                      //         radius: 38,
                      //         backgroundImage: profile['image'] != null && profile['image'] != ''
                      //             ? NetworkImage('https://admin-growup.onebitstore.site/storage/${profile['image']}')
                      //             : const AssetImage('assets/images/img.png') as ImageProvider,
                      //       ),
                      //       const SizedBox(width: 16),
                      //
                      //       // Info Column on the right
                      //       Expanded(
                      //         child: SingleChildScrollView(
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               // Name + Edit icon row
                      //               Row(
                      //                 children: [
                      //                   Expanded(
                      //                     child: Text(
                      //                       profile['name'] ?? 'No Name',
                      //                       style: const TextStyle(
                      //                         color: Colors.white,
                      //                         fontWeight: FontWeight.bold,
                      //                         fontSize: 18,
                      //                       ),
                      //                       overflow: TextOverflow.ellipsis,
                      //                     ),
                      //                   ),
                      //                   GestureDetector(
                      //                     onTap: () {
                      //                       Navigator.pushNamed(context, '/myprofile');
                      //                     },
                      //                     child: Image.asset(
                      //                       'assets/icons/edit.png',
                      //                       width: 20,
                      //                       height: 20,
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //               const SizedBox(height: 8),
                      //
                      //               // Code
                      //               Row(
                      //                 children: [
                      //                   const Icon(Icons.person, color: Colors.white70, size: 16),
                      //                   const SizedBox(width: 6),
                      //                   Expanded(
                      //                     child: Text(
                      //                       profile['code'] ?? '',
                      //                       style: const TextStyle(
                      //                         color: Colors.white70,
                      //                         fontSize: 12,
                      //                       ),
                      //                       overflow: TextOverflow.ellipsis,
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //               const SizedBox(height: 6),
                      //
                      //               // Phone
                      //               Row(
                      //                 children: [
                      //                   const Icon(Icons.phone, color: Colors.white70, size: 16),
                      //                   const SizedBox(width: 6),
                      //                   Expanded(
                      //                     child: Text(
                      //                       profile['phone'] ?? '',
                      //                       style: const TextStyle(
                      //                         color: Colors.white70,
                      //                         fontSize: 12,
                      //                       ),
                      //                       overflow: TextOverflow.ellipsis,
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //               const SizedBox(height: 6),
                      //
                      //               // Email
                      //               Row(
                      //                 children: [
                      //                   const Icon(Icons.email, color: Colors.white70, size: 16),
                      //                   const SizedBox(width: 6),
                      //                   Expanded(
                      //                     child: Text(
                      //                       profile['email'] ?? '',
                      //                       style: const TextStyle(
                      //                         color: Colors.white70,
                      //                         fontSize: 12,
                      //                       ),
                      //                       overflow: TextOverflow.ellipsis,
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                        ),
                        margin: EdgeInsets.zero,
                        accountName: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              profile['name'] ?? 'No Name',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 4), // minimal space
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/myprofile');
                              },
                              child: Image.asset(
                                'assets/icons/edit.png',
                                width: 28,
                                height: 28,
                                // Optional: apply color filter
                              ),
                            ),
                          ],
                        ),
                        accountEmail: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${profile['code']}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Text(
                            //   "ID: ${profile['code']}",
                            //   style: const TextStyle(
                            //     fontSize: 10,
                            //     color: Colors.white,
                            //   ),
                            // )
                          ],
                        ),

                        currentAccountPicture: CircleAvatar(
                          backgroundImage: profile['image'] != null && profile['image'].toString().isNotEmpty
                              ? NetworkImage(
                            "${ApiConstants.imgBaseUrl}/storage/${profile['image']}",
                          )
                              : const AssetImage('assets/images/img.png') as ImageProvider,
                        ),


                        // currentAccountPicture: CircleAvatar(
                        //   backgroundImage:
                        //       profile['image'] != null && profile['image'] != ''
                        //       ? NetworkImage(
                        //           'https://admin-growup.onebitstore.site/storage/${profile['image']}',
                        //         )
                        //       : const AssetImage('assets/images/img.png')
                        //             as ImageProvider,
                        // ),
                      ),

                      _buildDrawerItem(
                        Icons.dashboard_customize,
                        'Dashboard',
                        context,
                        '/dashboard',
                      ),
                      ExpansionTile(
                        leading: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.green,
                        ),
                        title: Text('Wallet'),
                        childrenPadding: EdgeInsets.only(
                          left: 40,
                        ), // Add left space for all children
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.wallet,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('My Wallet'),
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const WalletHistoryPage(),
                                ),
                              );
                            },
                          ),


                          ListTile(
                            leading: Icon(
                              Icons.upload,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Deposit'),
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DepositPage(),
                                ),
                              );
                            },
                          ),

                          ListTile(
                            leading: Icon(
                              Icons.arrow_downward,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Withdraw'),
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WithdrawPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: Icon(Icons.work, color: Colors.green),
                        title: Text('Growup'),
                        childrenPadding: EdgeInsets.only(
                          left: 40,
                        ), // Add left space for all children
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.account_balance_wallet,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Projects'),
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllProjectsPage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.upload,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Invested Projects'),
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyProjectsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: Icon(Icons.apartment, color: Colors.green),
                        title: Text('Properties'),
                        childrenPadding: EdgeInsets.only(
                          left: 40,
                        ), // Add left space for all children
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.inventory,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Package Details'),
                            onTap: () {
                              Navigator.pop(context); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AllPropertiesPage()),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.format_list_numbered,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Ordered Properties'),
                            onTap: () {
                              // Navigator.pop(context); // Close the drawer or dialog if needed
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => const MyProjectsPage()),
                              // );
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: Icon(Icons.agriculture, color: Colors.green),
                        title: Text('Products'),
                        childrenPadding: EdgeInsets.only(
                          left: 40,
                        ), // Add left space for all children
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.view_list,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('All Products'),
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllProductsPage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.list_alt,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('My Cart'),
                            onTap: () {
                              // Navigator.pop(context); // Close the drawer or dialog if needed
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => const DepositPage()),
                              // );
                            },
                          ),

                          ListTile(
                            leading: Icon(
                              Icons.widgets,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('My Orders'),
                            onTap: () {
                              Navigator.pop(context); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MyOrdersPage()),
                              );
                            },
                          ),

                          ListTile(
                            leading: Icon(
                              Icons.local_shipping,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Track My Orders'),
                            onTap: () {
                              // Navigator.pop(context); // Close the drawer or dialog if needed
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => const WithdrawPage()),
                              // );
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: Icon(Icons.receipt_long, color: Colors.green),
                        title: Text('Invoices'),
                        childrenPadding: EdgeInsets.only(
                          left: 40,
                        ), // Add left space for all children
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.work,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Growup'),
                            onTap: () {
                              Navigator.pop(context); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const InvoiceGrowupPage()),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.apartment,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Property'),
                            onTap: () {
                              // Navigator.pop(context); // Close the drawer or dialog if needed
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => const DepositPage()),
                              // );
                            },
                          ),

                          ListTile(
                            leading: Icon(
                              Icons.battery_charging_full,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Recharge'),
                            onTap: () {
                              Navigator.pop(context); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const InvoiceRechargePage()),
                              );
                            },
                          ),

                          ListTile(
                            leading: Icon(
                              Icons.show_chart,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('ROI'),
                            onTap: () {
                              Navigator.pop(context); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const InvoiceRoiPage()),
                              );
                            },
                          ),

                          ListTile(
                            leading: Icon(
                              Icons.savings,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Capital Return'),
                            onTap: () {
                              Navigator.pop(context); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CapitalReturnPage()),
                              );
                            },
                          ),
                        ],
                      ),

                      // _buildDrawerItem(Icons.work_outline, 'Projects', context, '/projects'),
                      // _buildDrawerItem(Icons.account_balance_wallet, 'My Projects', context, '/myprojects'),
                      _buildDrawerItem(
                        Icons.history,
                        'Investment History',
                        context,
                        '/investmenthistory',
                      ),

                      //_buildDrawerItem(Icons.account_balance_wallet_outlined, 'Wallet', context, '/Wallet'),
                      _buildDrawerItem(
                        Icons.person_outline,
                        'Profile',
                        context,
                        '/profile',
                      ),

                      ExpansionTile(
                        leading: Icon(Icons.verified, color: Colors.green),
                        title: Text('Certification'),
                        childrenPadding: EdgeInsets.only(
                          left: 40,
                        ), // Add left space for all children
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.article,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('TAX Certificate'),
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TaxCertificatePage(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.workspace_premium,
                              size: 28,
                              color: Colors.green,
                            ), // Bullet point
                            title: Text('Investment Certificate'),
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // Close the drawer or dialog if needed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProjectCertificatePage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.green),
                        title: const Text('Logout'),
                        onTap: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pop(false), // Cancel
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pop(true), // Confirm
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true) {
                            await _logout(); // This handles API + navigation
                          }
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),

        //Circle avatar ,text and wallet button
        appBar: _selectedIndex == 4
            ? null
            : AppBar(
                backgroundColor: const Color(0xFF2E7D32),
                centerTitle: true,
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                toolbarHeight: 70,
                elevation: 0,

                // Drawer avatar at the left
                leading: Builder(
                  builder: (context) => GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 10),
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: _profileFuture,
                        builder: (context, snapshot) {
                          Widget avatar;

                          if (!snapshot.hasData) {
                            avatar = ClipOval(
                              child: Image.asset(
                                'assets/images/img.png',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            );
                          } else {
                            final profile = snapshot.data!;
                            // final imageUrl =
                            //     profile['image'] != null &&
                            //         profile['image'].toString().isNotEmpty
                            //     ? 'https://admin-growup.onebitstore.site/storage/${profile['image']}'
                            //     : null;

                            final imageUrl = profile['image'] != null && profile['image'].toString().isNotEmpty
                                ? ApiConstants.getImageUrl(profile['image'])
                                : null;

                            avatar = ClipOval(
                              child: Image(
                                image: imageUrl != null
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage('assets/images/img.png')
                                          as ImageProvider,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            );
                          }

                          return Transform.translate(
                            offset: const Offset(0, 2),
                            child: AspectRatio(
                              aspectRatio:
                                  1, // Ensure the widget is always square
                              child: avatar,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Main content (name + balance)
                title: _isSearching
                    ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // Handle search here
                    print("Searching: $value");
                  },
                )
                    : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    // color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Username from API
                            FutureBuilder<Map<String, dynamic>>(
                              future: _profileFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return const Center(
                                    child: Text("Error fetching data"),
                                  );
                                } else {
                                  final profile = snapshot.data!;
                                  return Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Name
                                            Flexible(
                                              child: Text(
                                                "${profile['name']}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            const SizedBox(width: 6),

                                            // Loyalty Points
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber[700],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$_loyaltyPoints',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),


                                        // Text(
                                        //   "ID: ${profile['code']}",
                                        //   style: const TextStyle(
                                        //     fontSize: 10,
                                        //     color: Colors.white,
                                        //   ),
                                        // )
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),

                            // end of username api

                            // wallet balance
                            Container(
                              width: 160,
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 12,
                                top: 6,
                                bottom: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.green[700],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Image.asset(
                                      'assets/icons/img_5.png',
                                      fit: BoxFit.cover,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  Text(
                                    '$_walletBalance',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Notification bell on the right

          // Normal title
          actions: [
            // Search Icon
          IconButton(
          key: _searchKey,
          icon: const Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            final RenderBox renderBox =
            _searchKey.currentContext!.findRenderObject() as RenderBox;
            final Offset position = renderBox.localToGlobal(Offset.zero);

            // Move bar upward (subtract 10 px for example)
            final double popupTop = position.dy + renderBox.size.height - 30;

            showDialog(
              context: context,
              barrierColor: Colors.transparent, // no dark overlay
              builder: (context) {
                return Stack(
                  children: [
                    Positioned(
                      top: popupTop,
                      left: 0,
                      right: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.9), // white shadow
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),

        // Notification Bell
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                );
              },
            ),

            const SizedBox(width: 0), // optional spacing at the end
          ],


        ),

        body: _selectedIndex == 4
            ? const WebTabPage()
            : RefreshIndicator(
                onRefresh: _refreshDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // 👇 Insert your image carousel here
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 220.0,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 1.0, // 👈 makes each item full width
                          ),
                          items: imageUrls.map((url) {
                            return Builder(
                              builder: (BuildContext context) {
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width, // 👈 take full screen width
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),





                      IndexedStack(index: _selectedIndex,
                          children: _pages),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double cardWidth =
                                (constraints.maxWidth - 16) / 3; // 16 = 2 gaps of 8 pixels between cards

                            //counter
                            String formatValue(String value) {
                              try {
                                double numValue = double.tryParse(value) ?? 0.0;
                                return numValue.toStringAsFixed(2); // 2 digits after decimal
                              } catch (e) {
                                return value;
                              }
                            }

                            Widget buildCard(
                              String title,
                              String value,
                              IconData icon,
                            ) {
                              String displayValue = formatValue(value);
                              return Container(
                                width: cardWidth,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none, // allow positioning outside padding if needed
                                  children: [
                                    Center(
                                      child: _buildInnerCard(
                                        title,
                                        displayValue, // <-- use formatted value here
                                        icon,
                                      ),
                                    ),

                                    Positioned(
                                      top:
                                          -20, // a little padding from top edge
                                      right:
                                          -10, // a little padding from right edge
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.more_horiz,
                                          size: 16,
                                        ),
                                        padding: EdgeInsets.zero,
                                        splashRadius: 20,
                                        onPressed: () {
                                          if (title == 'Total Investment') {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  insetPadding: const EdgeInsets.all(12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const TotalInvestmentHistoryPage(),
                                                );
                                              },
                                            );
                                          } else if (title == "Today's Income") {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  insetPadding: const EdgeInsets.all(12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const TodaysIncomeDialog(),
                                                );
                                              },
                                            );
                                          } else if (title == "Total Income") {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  insetPadding: const EdgeInsets.all(12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const TotalIncomeDialog(),
                                                );
                                              },
                                            );
                                          } else if (title == "My Grow Up Projects") {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  insetPadding: const EdgeInsets.all(12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const MyGrowupProjectsDialog(),
                                                );
                                              },
                                            );
                                          } else if (title == "Wallet Balance") {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  insetPadding: const EdgeInsets.all(12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const WalletHistoryDialog(),
                                                );
                                              },
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Details'),
                                                  content: Text('Here are more details about "$title".'),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                      ),
                                                      child: const Text(
                                                        "Close",
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),

                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              children: [
                                // Row 1: Two half-width cards
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildCard(
                                        'Today\'s Income',
                                        todaysIncome.toString(),
                                        Icons.monetization_on,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: buildCard(
                                        'Total Income',
                                        totalIncome.toString(),
                                        Icons.account_balance_wallet,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Row 2: Full-width Wallet Balance card with image
                                // buildFullImageCard(
                                //   context,
                                //   'Wallet Balance',
                                //   totalwallet_balance.toString(),
                                //   'assets/images/img_2.png', // your image
                                // ),
                                // const SizedBox(height: 8),

                                // Row 3: Two half-width cards
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildCard(
                                        'My Grow Up Projects',
                                        totalProjects.toString(),
                                        Icons.auto_graph,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: buildCard(
                                        'Ordered Properties',
                                        '0',
                                        Icons.home_work_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100, // card height
                                  width: double.infinity,
                                  child: PageView(
                                    controller: PageController(viewportFraction: 1.02), // full width minus small space
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4), // space between cards
                                        child: buildFullImageCard(
                                          context,
                                          "Total Investment",
                                          totalInvestment.toString(),
                                          "assets/images/img_1.png",
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4), // space between cards
                                        child: buildFullImageCard(
                                          context,
                                          "Wallet Balance",
                                          totalwallet_balance.toString(),
                                          "assets/images/img_2.png",
                                        ),
                                      ),
                                      // Add more cards here
                                    ],
                                  ),
                                ),

                                // Row 4: Full-width Total Investment card with image
                                // buildFullImageCard(
                                //   context,
                                //   'Total Investment',
                                //   totalInvestment.toString(),
                                //   'assets/images/img_1.png', // your image
                                // ),
                              ],
                            );

                          },
                        ),
                      ),

                      // Image carousel
                      // CarouselSlider(
                      //   options: CarouselOptions(
                      //     height: 200.0,
                      //     autoPlay: true,
                      //     enlargeCenterPage: true,
                      //     viewportFraction: 0.9,
                      //   ),
                      //   items: imageUrls.map((url) {
                      //     return Builder(
                      //       builder: (BuildContext context) {
                      //         return ClipRRect(
                      //           borderRadius: BorderRadius.circular(12),
                      //           child: Image.network(
                      //             url,
                      //             fit: BoxFit.cover,
                      //             width: double.infinity,
                      //             loadingBuilder: (context, child, progress) {
                      //               if (progress == null) return child;
                      //               return const Center(child: CircularProgressIndicator());
                      //             },
                      //             errorBuilder: (context, error, stackTrace) {
                      //               return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                      //             },
                      //           ),
                      //         );
                      //       },
                      //     );
                      //   }).toList(),
                      // ),


                      // const SizedBox(height: 16),
                      // ✅ Carousel / Banner
                      // const SizedBox(height: 16),
                      // isLoading
                      //     ? const Center(child: CircularProgressIndicator())
                      //     : sliders.isEmpty
                      //     ? const Center(child: Text("No sliders available."))
                      //     : CarouselSlider(
                      //   options: CarouselOptions(
                      //     height: 100,
                      //     autoPlay: true,
                      //     enlargeCenterPage: true,
                      //     viewportFraction: 0.6,
                      //     autoPlayInterval: const Duration(seconds: 3),
                      //   ),
                      //   items: sliders.map((item) {
                      //     return ClipRRect(
                      //       borderRadius: BorderRadius.circular(10),
                      //       child: Image.network(
                      //         item.imageUrl,
                      //         fit: BoxFit.cover,
                      //         width: double.infinity,
                      //         errorBuilder: (context, error, stackTrace) =>
                      //         const Icon(Icons.broken_image),
                      //       ),
                      //     );
                      //   }).toList(),
                      // ),

                      // ✅ Horizontal Info Cards
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: LayoutBuilder(
                      //     builder: (context, constraints) {
                      //       double cardWidth = constraints.maxWidth;
                      //
                      //       // First composite card (with 3 metrics)
                      //       final Widget firstRowCard = _buildCompositeCard(
                      //         cardWidth,
                      //         [
                      //           _buildInnerCard('Total Transaction', totalTransation.toString(), Icons.history),
                      //           _buildInnerCard('Total Investment', totalInvestment.toString(), Icons.pie_chart),
                      //           _buildInnerCard('Total Income', totalIncome.toString(), Icons.attach_money),
                      //         ],
                      //       );
                      //
                      //       // Second composite card (with 3 metrics)
                      //       final Widget secondRowCard = _buildCompositeCard(
                      //         cardWidth,
                      //         [
                      //           _buildInnerCard('Today\'s Income', todaysIncome.toString(), Icons.trending_up),
                      //           _buildInnerCard('Ordered Properties', '0', Icons.reorder),
                      //           _buildInnerCard('My grow up projects', totalProjects.toString(), Icons.assessment),
                      //         ],
                      //       );
                      //
                      //       return Column(
                      //         children: [
                      //           firstRowCard,
                      //           const SizedBox(height: 8),
                      //           if (_showAllCards) secondRowCard,
                      //           const SizedBox(height: 0),
                      //           Center(
                      //             child: TextButton(
                      //               onPressed: () {
                      //                 setState(() {
                      //                   _showAllCards = !_showAllCards;
                      //                 });
                      //               },
                      //               style: TextButton.styleFrom(
                      //                 foregroundColor: Colors.orange,
                      //                 padding: EdgeInsets.zero,
                      //                 minimumSize: const Size(0, 30),
                      //                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      //               ),
                      //               child: Row(
                      //                 mainAxisSize: MainAxisSize.min,
                      //                 children: [
                      //                   Text(
                      //                     _showAllCards ? "Close" : "See More",
                      //                     style: const TextStyle(fontSize: 10),
                      //                   ),
                      //                   const SizedBox(width: 6),
                      //                   Icon(
                      //                     _showAllCards ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      //                     size: 18,
                      //                     color: Colors.orange,
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       );
                      //     },
                      //   ),
                      // ),

                      // Growup Investment by category
                      Card(
                        elevation: 5,
                          color:Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8, left: 8, right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row with asset icon on the right
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //crossAxisAlignment: CrossAxisAlignment.start, // align top
                                children: [
                                  // Left side: two lines of text
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'GROWUP',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 13,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'INVESTMENT BY CATEGORY',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Right side: icon
                                  Image.asset(
                                    'assets/icons/Shariah.png',
                                    width: 60,
                                    height: 60,
                                  ),
                                ],
                              ),
                        
                              //const SizedBox(height: 5),
                              Container(
                                // elevation: 4, // subtle shadow
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(16), // rounded corners
                                // ),
                                //margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // card margin
                                color: Colors.white, // card background
                                child: Column(
                                  children: [
                                    // First row: All Projects, Live Projects, Matured Projects
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: _buildCategoryButton5(
                                            'All Projects',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildCategoryButton4(
                                            'Live Projects',
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildCategoryButton11(
                                            'Matured',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4), // space between rows

                                    // Second row: Short Projects, Long Projects
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: _buildCategoryButton3(
                                            'Short Projects',
                                            Icons.hourglass_bottom,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildCategoryButton2(
                                            'Long Projects',
                                            Icons.access_time,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      // Properties Investment by category
                      Card(
                        elevation: 5,
                        color:Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8, left: 8, right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row with static icon on the right
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //crossAxisAlignment: CrossAxisAlignment.start, // align top
                                children: [
                                  // Left side: two lines of text
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PROPERTIES',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 13,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'INVESTMENT BY CATEGORY',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Right side: icon
                                  Image.asset(
                                    'assets/icons/Secure.png',
                                    width: 60,
                                    height: 60,
                                    //color: Colors.green, // Optional: apply color tint
                                  ),
                                ],
                              ),

                              //const SizedBox(height: 5),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Expanded(
                              //       child: _buildCategoryButton6(
                              //         'Residential',
                              //         Icons.apartment,
                              //       ),
                              //     ),
                              //     const SizedBox(width: 8),
                              //     Expanded(
                              //       child: _buildCategoryButton7(
                              //         'Hi-Tech City',
                              //         Icons.memory,
                              //       ),
                              //     ),
                              //     const SizedBox(width: 8),
                              //     Expanded(
                              //       child: _buildCategoryButton8(
                              //         'Eco City',
                              //         Icons.grass,
                              //       ),
                              //     ),
                              //     const SizedBox(width: 8),
                              //     Expanded(
                              //       child: _buildCategoryButton9(
                              //         'Health Sector',
                              //         Icons.medical_services,
                              //       ),
                              //     ),
                              //   ],
                              // ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.10,
                            child: PageView(
                              controller: PageController(viewportFraction: 1.0),
                              children: [
                                _buildCategoryButton6(
                                  "Residential City",
                                  Icons.apartment,
                                  "https://www.bproperty.com/blog/wp-content/uploads/IMG_5881-1170x508.jpg",
                                ),
                                _buildCategoryButton6(
                                  "Hi-Tech City",
                                  Icons.memory,
                                  "https://mediaim.expedia.com/destination/9/1c4ff5299a91c4fbdc07a174eeed8864.jpg",
                                ),
                                _buildCategoryButton6(
                                  "Eco City",
                                  Icons.grass,
                                  "https://thumbs.dreamstime.com/b/eco-city-green-living-concept-52747245.jpg",
                                ),
                                _buildCategoryButton6(
                                  "Health Sector",
                                  Icons.medical_services,
                                  "https://visaenvoy.com/wp-content/uploads/2022/04/Health-Sector.png",
                                ),
                              ],
                            ),
                          ),


                          ],
                          ),
                        ),
                      ),

                      // Projects you may invest
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 0, left: 8, right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'PROJECTS YOU MAY INVEST',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AllProjectsPage(),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      Text(
                                        'See All',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // const Divider(thickness: 1.2),
                            FutureBuilder<List<ShariahProject>>(
                              future: fetchShariahProjects(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text('No projects available.'),
                                  );
                                }

                                final projects = snapshot.data!;
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: projects.map((project) {
                                      return Row(
                                        children: [
                                          _buildProjectCard(
                                            context:
                                                context, // Pass context here
                                            imageUrl: project.imageUrl ?? '',
                                            projectId:
                                                project.id?.toString() ?? '',
                                            name: project.projectName ?? 'N/A',
                                            type:
                                                project.investmentType_name ??
                                                "N/A",
                                            goal:
                                                '${project.investmentGoal ?? '0'} Tk',
                                            duration:
                                                project
                                                    .project_duration_viewer ??
                                                'N/A',
                                            minInvestment:
                                                '${project.minInvestmentAmount ?? '0'} Tk',
                                            time:
                                                '${project.remaining_opportunity_days ?? 0} Days',
                                            roi: '${project.annualRoi ?? 0}%',
                                            isTablet:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width >=
                                                600, // ✅ added
                                          ),
                                          const SizedBox(width: 15),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      //  Properties For You (Static cards)
                      // ... (as you already have it)

                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PROPERTIES YOU MAY INVEST',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    //Navigator.pop(context); // Close the drawer or dialog if needed
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AllPropertiesPage()),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'See All',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: FutureBuilder<AllPropertiesResponse>(
                                future: fetchProperties(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text("Error: ${snapshot.error}"));
                                  } else if (!snapshot.hasData || snapshot.data!.propertyPackages.isEmpty) {
                                    return const Center(child: Text("No properties found"));
                                  }

                                  final propertyPackages = snapshot.data!.propertyPackages;

                                  // Limit to 3 properties
                                  final firstThree = propertyPackages.take(3).toList();

                                  return ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: firstThree.length,
                                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                                    itemBuilder: (context, index) {
                                      final package = firstThree[index];
                                      return _buildPropertyCard(
                                        context: context,
                                        imageUrl: "https://admin-growup.onebitstore.site${package.imageUrl}",
                                        propertyName: package.propertyName,
                                        packageName: package.packageName,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),


                          ],
                        ),
                      ),
                    ),

                    // Transactions
                      Card(
                        elevation: 5,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Transaction title
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'TRANSACTION',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              WalletHistoryPage(),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          'See All',
                                          style: TextStyle(
                                            color: Colors.orange,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.orange,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(thickness: 1.2, color: Colors.green,),

                              if (_walletTransactions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text('No recent transactions.'),
                                )
                              else
                                ..._walletTransactions.take(3).map((tx) {
                                  final String type =
                                      tx['type']?.toString().toLowerCase() ??
                                      '';
                                  IconData icon;

                                  if (type == 'withdraw') {
                                    icon = Icons.arrow_downward;
                                  } else if (type == 'deposit') {
                                    icon = Icons.arrow_upward;
                                  } else if (type == 'investment') {
                                    icon = Icons.bar_chart;
                                  } else {
                                    icon = Icons.help_outline;
                                  }

                                  return _buildTransactionItem(
                                    icon,
                                    tx['type'].toString().toUpperCase(),
                                    tx['created_at'] ?? '',
                                    '${tx['amount']} Tk',
                                    tx['status'] ?? 'N/A',
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        // bottomNavigationBar: CustomBottomNavBar(
        //   selectedIndex: _selectedIndex,
        //   onItemTapped: _onItemTapped,
        // ),
      ),
    );
  }

  // left drawer
  ListTile _buildDrawerItem(
    IconData icon,
    String title,
    BuildContext context,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // close the drawer first
        Navigator.pushNamed(context, route);
      },
    );
  }

  // Total Investment, income and today's income function
  Widget _buildCompositeCard(double width, List<Widget> innerCards) {
    return SizedBox(
      width: width,
      child: Card(
        color: Colors.white, // Explicitly set white color
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Ensure inner container is also white
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          height: 100,
          child: Row(
            children: List.generate(innerCards.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Container(
                  width: 1,
                  height: double.infinity,
                  color: Colors.grey.shade300,
                );
              }
              return Expanded(child: innerCards[index ~/ 2]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildInnerCard(String title, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

// imagecard
  Widget buildFullImageCard(
      BuildContext context,
      String title,
      String value,
      String imagePath,
      ) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),

            // 👇 Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // adjust strength
              child: Container(
                color: Colors.black.withOpacity(0.3), // dark overlay
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      '৳ $value',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Three-dot button
            Positioned(
              top: -6,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                splashRadius: 20,
                onPressed: () {
                  if (title == "Wallet Balance") {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return Dialog(
                          insetPadding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const WalletHistoryDialog(),
                        );
                      },
                    );
                  } else if (title == 'Total Investment') {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return Dialog(
                          insetPadding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const TotalInvestmentHistoryPage(),
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Details'),
                          content: Text(
                            'Here are more details about "$title".',
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                "Close",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //// Total Investment, income and today's income function end

  // Investment by category function

  //Long Duration
  Widget _buildCategoryButton2(String label, IconData icon) {
    return SizedBox(
      width: double.infinity, // full width
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LongProjectsPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // transparent background
            shadowColor: Colors.transparent,     // remove shadow
            foregroundColor: Colors.green[700],  // text/icon color
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Colors.grey,  // border color
                width: 1,            // border width
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //short Duration
  Widget _buildCategoryButton3(String label, IconData icon) {
    return SizedBox(
      width: double.infinity, // full width
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShortProjectsPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // transparent background
            shadowColor: Colors.transparent,     // remove shadow
            foregroundColor: Colors.green[700],  // text/icon color
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Colors.grey,  // border color
                width: 1,            // border width
              ),
            ),
            padding: const EdgeInsets.all(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }


  //live
  Widget _buildCategoryButton4(String label,) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: double.infinity, // Adjust width as needed
        height: 50, // Adjust height as needed
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShariahProjectsPage(),
              ),
            );
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // transparent background
            shadowColor: Colors.transparent,     // remove shadow
            foregroundColor: Colors.green[700],  // text/icon color
            elevation: 2,                        // no elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Colors.grey,  // border color
                width: 1,            // border width
              ),
            ),
            padding: const EdgeInsets.all(12),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Icon(icon, size: 28),
              //const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //upcoming
  Widget _buildCategoryButton10(String label, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 80, // Adjust width as needed
        height: 80, // Adjust height as needed
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UpcomingProjectsPage(),
              ),
            );
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEBFEDE), // fully transparent
            shadowColor: const Color(0xFFEBFEDE), // remove shadow
            foregroundColor: Colors.green[700], // icon/text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey!, width: 0), // outline
            ),
            padding: const EdgeInsets.all(12),
            elevation: 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Matured
  Widget _buildCategoryButton11(String label) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: double.infinity, // Adjust width as needed
        height: 50, // Adjust height as needed
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CompletedProjectsPage(),
              ),
            );
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // transparent background
            shadowColor: Colors.transparent,     // remove shadow
            foregroundColor: Colors.green[700],  // text/icon color
            elevation: 2,                        // no elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Colors.grey,  // border color
                width: 1,            // border width
              ),
            ),
            padding: const EdgeInsets.all(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Icon(icon, size: 28),
              //const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //All projects
  Widget _buildCategoryButton5(String label) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: double.infinity,// Adjust width as needed
        height: 50, // Adjust height as needed
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllProjectsPage()),
            );
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // transparent background
            shadowColor: Colors.transparent,     // remove shadow
            foregroundColor: Colors.green[700],  // text/icon color
            elevation: 2,                        // no elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Colors.grey,  // border color
                width: 1,            // border width
              ),
            ),
            padding: const EdgeInsets.all(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Icon(icon, size: 28),
              //const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Residential city
  Widget _buildCategoryButton6(String label, IconData icon, String imageUrl) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isTablet = screenWidth >= 600;
    final cardHeight = isTablet ? screenHeight * 0.18 : screenHeight * 0.10;
    final cardWidth = screenWidth * 0.95;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResidencialCityPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      size: 40, color: Colors.grey),
                ),
              ),

              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5), // adjust strength
                child: Container(
                  color: Colors.black.withOpacity(0.3), // dark overlay
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // Icon + Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(icon,
                        size: isTablet ? screenWidth * 0.04 : 28,
                        color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet
                              ? screenWidth * 0.022
                              : screenWidth * 0.040,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // // residential
  // Widget _buildCategoryButton6(String label, IconData icon) {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: SizedBox(
  //       height: 100, // You can adjust height as needed
  //       child: ElevatedButton(
  //         onPressed: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => const ResidencialCityPage(),
  //             ),
  //           );
  //         },
  //         style: ElevatedButton.styleFrom(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           padding: const EdgeInsets.all(12),
  //           backgroundColor: Colors.white,
  //           foregroundColor: Colors.green[700],
  //           elevation: 0,
  //         ),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(icon, size: 28),
  //             const SizedBox(height: 8),
  //             Text(
  //               label,
  //               style: const TextStyle(
  //                 color: Colors.grey,
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // //Hi tech city
  // Widget _buildCategoryButton7(String label, IconData icon) {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: SizedBox(
  //       width: 120, // Adjust width as needed
  //       height: 100, // Adjust height as needed
  //       child: ElevatedButton(
  //         onPressed: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const HitechCityPage()),
  //           );
  //         },
  //
  //         style: ElevatedButton.styleFrom(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           padding: const EdgeInsets.all(12),
  //           backgroundColor: Colors.white,
  //           foregroundColor: Colors.green[700],
  //           elevation: 0,
  //         ),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(icon, size: 28),
  //             const SizedBox(height: 8),
  //             Text(
  //               label,
  //               style: const TextStyle(
  //                 color: Colors.grey,
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // //Eco city
  // Widget _buildCategoryButton8(String label, IconData icon) {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: SizedBox(
  //       width: 120, // Adjust width as needed
  //       height: 100, // Adjust height as needed
  //       child: ElevatedButton(
  //         onPressed: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const EcoCityPage()),
  //           );
  //         },
  //
  //         style: ElevatedButton.styleFrom(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           padding: const EdgeInsets.all(12),
  //           backgroundColor: Colors.white,
  //           foregroundColor: Colors.green[700],
  //           elevation: 0,
  //         ),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(icon, size: 28),
  //             const SizedBox(height: 8),
  //             Text(
  //               label,
  //               style: const TextStyle(
  //                 color: Colors.grey,
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // //health care
  // Widget _buildCategoryButton9(String label, IconData icon) {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: SizedBox(
  //       width: 120, // Adjust width as needed
  //       height: 100, // Adjust height as needed
  //       child: ElevatedButton(
  //         onPressed: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const HealthcarePage()),
  //           );
  //         },
  //
  //         style: ElevatedButton.styleFrom(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           padding: const EdgeInsets.all(12),
  //           backgroundColor: Colors.white,
  //           foregroundColor: Colors.green[700],
  //           elevation: 0,
  //         ),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(icon, size: 28),
  //             const SizedBox(height: 8),
  //             Text(
  //               label,
  //               style: const TextStyle(
  //                 color: Colors.grey,
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Projects you may invest function
  Widget _buildProjectCard({
    required BuildContext context,
    required String imageUrl,
    required String projectId,
    required String name,
    required String type,
    required String goal,
    required String duration,
    required String minInvestment,
    required String time,
    required String roi,
    required bool isTablet,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isTablet = screenWidth >= 600;
    final cardHeight = isTablet ? screenHeight * 0.48 : screenHeight * 0.18;
    final cardWidth = screenWidth * 0.97;

    final imageWidth = cardWidth * 0.28;
    final imageHeight = cardHeight * 0.85;

    final buttonWidth = cardWidth * 0.25;
    final buttonHeight = cardHeight * 0.18;

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.symmetric(
        //vertical: screenHeight * 0.01,
        // horizontal: screenWidth * 0.010,
      ),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Image
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: screenWidth * 0.06),
                ),
              ),
            ),
          ),

          // Right side
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.028,
                    horizontal: screenWidth * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          //fontSize: screenWidth * 0.036,
                          fontSize: isTablet
                              ? screenWidth * 0.022
                              : screenWidth * 0.036,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.005),

                      // Info fields
                      _infoRow(
                        label: 'Type:',
                        value: type,
                        fontSize: isTablet
                            ? screenWidth * 0.022
                            : screenWidth * 0.028,
                      ),
                      _infoRow(
                        label: 'Goal:',
                        value: goal,
                        fontSize: isTablet
                            ? screenWidth * 0.022
                            : screenWidth * 0.028,
                      ),
                      _infoRow(
                        label: 'Duration:',
                        value: duration,
                        fontSize: isTablet
                            ? screenWidth * 0.022
                            : screenWidth * 0.028,
                      ),
                      _infoRow(
                        label: 'Min Invest:',
                        value: minInvestment,
                        fontSize: isTablet
                            ? screenWidth * 0.022
                            : screenWidth * 0.028,
                      ),
                      _infoRow(
                        label: 'Time:',
                        value: time,
                        fontSize: isTablet
                            ? screenWidth * 0.022
                            : screenWidth * 0.028,
                      ),
                    ],
                  ),
                ),

                // ROI Badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: screenWidth * 0.03,
                          color: Colors.white,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          'ROI $roi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet
                                ? screenWidth * 0.022
                                : screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // "Invest Now" Button
                Positioned(
                  bottom: cardHeight * 0.19,
                  right: -buttonWidth * 0.38,
                  child: Transform.rotate(
                    angle: -1.5708,
                    child: SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final parsedProjectId = int.tryParse(projectId);
                          final prefs = await SharedPreferences.getInstance();
                          final investorCode =
                              prefs.getString('investor_code') ?? '';

                          if (parsedProjectId != null &&
                              investorCode.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProjectDescriptionPage(
                                  projectId: parsedProjectId,
                                  investorCode: investorCode,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF61B15A),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                        child: Text(
                          'Invest Now',
                          style: TextStyle(
                            fontSize: isTablet
                                ? screenWidth * 0.022
                                : screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  //helper method Projects you may invest function
  Widget _infoRow({
    required String label,
    required String value,
    double fontSize = 10,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: fontSize),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // properties you may invest

  // Properties for you function
  Widget _buildPropertyCard({
    required BuildContext context,
    required String imageUrl,
    required String propertyName,
    required String packageName,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth >= 600;

    final cardWidth = isTablet ? screenWidth * 0.5 : screenWidth * 0.97;
    final cardHeight = isTablet ? screenHeight * 0.45 : screenHeight * 0.25;

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: cardHeight * 0.55,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              propertyName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.green,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              packageName,
              style: const TextStyle(fontSize: 12, color: Colors.black),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Spacer(),

          // Button flush with bottom card edges
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllPropertiesPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                elevation: 0, // match card shadow
              ),
              child: const Text(
                'See Details',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //end

  // Properties for you function
  // Widget _buildPropertyCard({
  //   required String imageUrl,
  //   required String title,
  //   required String location,
  // }) {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.vertical,
  //       child: Card(
  //         elevation: 5,
  //         child: Container(
  //           width: 200, // Adjust width for wrapping
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.circular(8),
  //                   child: Image.network(
  //                     imageUrl,
  //                     height: 100,
  //                     width: double.infinity,
  //                     fit: BoxFit.cover,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   title,
  //                   style: const TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 Text(location, style: const TextStyle(fontSize: 12)),
  //                 const SizedBox(height: 8),
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 25.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     children: [
  //                       ElevatedButton(
  //                         onPressed: () {},
  //                         child: const Text(
  //                           'See Details',
  //                           style: TextStyle(color: Colors.white, fontSize: 10),
  //                         ),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.green,
  //                           foregroundColor: Colors.white, // text/icon color
  //                           padding: const EdgeInsets.symmetric(
  //                             horizontal: 6,
  //                             vertical: 2,
  //                           ),
  //                           minimumSize: Size(0, 24), // ↓ minimum height
  //                           tapTargetSize: MaterialTapTargetSize
  //                               .shrinkWrap, // ↓ reduce extra padding
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(6),
  //                           ),
  //                         ),
  //                       ),
  //
  //                       SizedBox(width: 10),
  //                       ElevatedButton(
  //                         onPressed: () {},
  //                         child: const Text(
  //                           'Order Now',
  //                           style: TextStyle(color: Colors.white, fontSize: 10),
  //                         ),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.orange,
  //                           foregroundColor: Colors.white,
  //                           padding: const EdgeInsets.symmetric(
  //                             horizontal: 6,
  //                             vertical: 2,
  //                           ),
  //                           minimumSize: Size(0, 24),
  //                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(6),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Transaction function
  Widget _buildTransactionItem(
    IconData icon,
    String title,
    String rawDate,
    String amount,
    String status,
  ) {
    // Parse and format date
    String formattedDate = '';
    try {
      DateTime parsedDate = DateTime.parse(rawDate);
      formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      formattedDate = rawDate; // fallback in case of invalid format
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: status.toLowerCase() == 'approved'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: status.toLowerCase() == 'approved'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    await fetchAndSaveInvestorProfile(); // updates SharedPreferences
    await fetchWalletBalance(); // updates SharedPreferences

    // Wait for both to finish before loading the values
    await _loadDashboardData(); // reads SharedPreferences

    final walletList = await fetchWalletHistory();

    setState(() {
      _profileFuture = getInvestorProfileFromPrefs(); // updates UI profile
      _walletTransactions = walletList
          .map(
            (e) => {
              'type': e.type,
              'created_at': e.createdAt,
              'amount': e.amount,
              'status': e.status ?? 'N/A',
              'trx_id': e.trxId,
            },
          )
          .toList();
    });
  }
}
