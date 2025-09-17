import 'package:flutter/material.dart';
import 'package:growup_agro/views/IntroPage.dart';
import 'package:growup_agro/views/ProfilePage.dart';
import 'package:growup_agro/views/all_products_page.dart';
import 'package:growup_agro/views/all_projects.dart';
import 'package:growup_agro/views/all_properties.dart';
import 'package:growup_agro/views/desposit_page.dart';
import 'package:growup_agro/views/investment_history.dart';
import 'package:growup_agro/views/investor_dashboard.dart';
import 'package:growup_agro/views/invoice_capital_return.dart';
import 'package:growup_agro/views/invoice_growup.dart';
import 'package:growup_agro/views/invoice_recharge.dart';
import 'package:growup_agro/views/invoice_roi.dart';
import 'package:growup_agro/views/my_orders_page.dart';
import 'package:growup_agro/views/my_projects.dart';
import 'package:growup_agro/views/project_certificate_page.dart';
import 'package:growup_agro/views/shariah.dart';
import 'package:growup_agro/views/tax_certificate.dart';
import 'package:growup_agro/views/wallet_history.dart';
import 'package:growup_agro/views/withdraw_page.dart';
import 'package:growup_agro/widgets/bottom_nav_bar.dart';
import 'package:growup_agro/widgets/webview_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;
  int _bottomNavIndex = 2;
  late Future<Map<String, dynamic>> _profileFuture;

  final List<Widget> _pages = const [
    AllProjectsPage(), //index 0
    AllProjectsPage(),
    DashboardInvestor(),
    AllProductsPage(),
    WebTabPage(),//index
    // WalletHistoryPage(),
    // DepositPage(),
    // InvestorProfilePage(),
  ];

  // Add this method here inside the class:
  void _selectPageFromDrawer(int index) {
    Navigator.of(context).pop(); // close drawer
    setState(() {
      _selectedIndex = index; // update the selected page
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      setState(() {
        _bottomNavIndex = index;
        _selectedIndex = index; // they match only for nav bar items
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final investorCode = prefs.getString('investor_code') ?? '';

    final url = Uri.parse(
      'https://admin-growup.onebitstore.site/api/investor/logout',
    );

    try {
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

  // Future<void> _logoutAndGoToIntro() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('username');
  //   await prefs.remove('password');
  //
  //   Navigator.of(context).pushAndRemoveUntil(
  //     MaterialPageRoute(builder: (_) => const IntroPage()),
  //         (route) => false,
  //   );
  // }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        backgroundColor: const Color(0xFFFFFFFF), // your desired background color here
    child: ListView(

      padding: const EdgeInsets.only(top: 54, left: 0, right: 0, bottom: 0), // Add top padding
      children: [
        // Align(
        //   alignment: Alignment.topLeft,
        //   child: IconButton(
        //     icon: const Icon(
        //       Icons.close,
        //       color: Colors.red,
        //       size: 30, // Bigger size than default (default is 24)
        //     ),
        //     tooltip: 'Close Drawer',
        //     onPressed: () {
        //       Navigator.of(context).pop(); // Close the drawer
        //     },
        //   ),
        // ),

        // _buildDrawerItem(
        //   Icons.dashboard_customize,
        //   'Dashboard',
        //   context,
        //   '/dashboard',
        //
        // ),


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
            // ListTile(
            //   leading: Icon(
            //     Icons.wallet,
            //     size: 28,
            //     color: Colors.green,
            //   ), // Bullet point
            //   title: Text('My Wallet'),
            //   onTap: () {
            //     Navigator.pop(
            //       context,
            //     ); // Close the drawer or dialog if needed
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) =>
            //         const WalletHistoryPage(),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.wallet, size: 28, color: Colors.green),
              title: Text('My Wallet'),
              onTap: () {
                  Navigator.pop(context); // Close the drawer or dialog if needed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WalletHistoryPage()),
                  );
                // Navigator.pop(context); // close drawer
                // setState(() {
                //   _selectedIndex = 5; // WalletHistoryPage
                // });
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
        _buildDrawerItem(
          Icons.history,
          'Investment History',
          context,
          '/investmenthistory',
        ),
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
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true) {
              await _logout();
            }
          },
        ),
      ],
    ),
    ),

    body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _bottomNavIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Sample drawer item builder
  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.pushNamed(context, route); // Use named routes or replace with MaterialPageRoute
      },
    );
  }



  // Dummy profile fetcher - replace with your real implementation
  Future<Map<String, dynamic>> fetchInvestorProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    return {'name': 'Investor'};
  }

  // Future<void> _logout() async {
  //   // Your logout logic
  //   Navigator.pushReplacementNamed(context, '/login');
  // }
}
