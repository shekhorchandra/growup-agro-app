import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';




// Secure storage instance (global for this file)
final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> with TickerProviderStateMixin {

  late AnimationController _logoController;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;

  late AnimationController _formController;
  late Animation<double> _formOpacity;
  late Animation<Offset> _formSlide;

  bool hidePassword = true;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool isLoading = false;
  bool isForgotLoading = false;
  bool isSignUpLoading = false;
  //Initialize and Load Checkbox State
  @override
  void initState()  {
    super.initState();
    print('initState called');
    _loadRememberMeValue();
// Initialize animation controllers
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _formOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeIn),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOut),
    );

    // Stagger animation
    Timer(const Duration(milliseconds: 200), () {
      _logoController.forward();
    });
    Timer(const Duration(milliseconds: 800), () {
      _formController.forward();
    });

  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }




  //forget pass start
  Future<void> handleForgotPassword() async {
    final uri = Uri.parse('https://admin-growup.onebitstore.site/api/forgot-password');
    // final uri = Uri.parse(ApiConstants.forgotPassword);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final redirectUrl = data['redirect_url'];

        if (redirectUrl != null) {
          await launchUrlString(redirectUrl, mode: LaunchMode.externalApplication);
        } else {
          print('Redirect URL is null');
        }

      } else {
        // Handle error response
        print('Failed to call forgot password API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  //forget pass end

  //remember me cache
  Future<void> _loadRememberMeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool val = prefs.getBool('remember_me') ?? false;

    if (val) {
      String? storedUsername = await secureStorage.read(key: 'username');
      String? storedPassword = await secureStorage.read(key: 'password');

      if (storedUsername != null) {
        usernameController.text = storedUsername;
      }
      if (storedPassword != null) {
        passwordController.text = storedPassword;
      }
    }

    setState(() {
      rememberMe = val;
    });
  }


  Future<void> _updateRememberMeValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
    setState(() {
      rememberMe = value;
    });

    if (value) {
      await secureStorage.write(key: 'username', value: usernameController.text);
      await secureStorage.write(key: 'password', value: passwordController.text);
    } else {
      await secureStorage.delete(key: 'username');
      await secureStorage.delete(key: 'password');
    }
  }

  // Remember me cache end


// finish Initialize and Load Checkbox State

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/GrowUPlogin.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: height * 0.06),
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/GrowupLogo.png',
                              color: Colors.white,
                              height: height * 0.23,
                              width: width * 0.6,
                              fit: BoxFit.contain,
                            ),
                            const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _formOpacity,
                      child: SlideTransition(
                        position: _formSlide,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                          child: _buildLoginForm(context),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller: usernameController,
          hintText: "Enter your email or phone no",
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: passwordController,
          hintText: "Enter your password",
          icon: Icons.key,
          obscureText: hidePassword,
          suffixIcon: IconButton(
            onPressed: () => setState(() => hidePassword = !hidePassword),
            icon: Icon(
              hidePassword ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: Colors.green,
            ),
          ),
        ),
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: (value) {
                if (value != null) _updateRememberMeValue(value);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: Colors.white),
              fillColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => states.contains(MaterialState.selected) ? Colors.white : Colors.transparent),
              checkColor: Colors.black,
            ),
            const Text(
              'Remember me',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
            final username = usernameController.text.trim();
            final password = passwordController.text.trim();

            if (username.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter both username and password")),
              );
              return;
            }

            setState(() => isLoading = true);
            try {
              final token = await login(context, username, password);
              print('Token: $token'); // or store it
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Login successful"), backgroundColor: Colors.green),
              );
              Navigator.pushReplacementNamed(context, '/mainscreen');

              // Navigator.pushReplacementNamed(context, '/dashboard');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Invalid email or password"),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              setState(() => isLoading = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : const Text('Login', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        const SizedBox(height: 12),
        // TextButton(
        //   onPressed: () => handleForgotPassword(),
        //   child: Column(
        //     children: const [
        //       Text('Forgot Password?', style: TextStyle(color: Colors.green, fontSize: 15)),
        //       SizedBox(height: 2),
        //       SizedBox(width: 130, child: Divider(color: Colors.white24, thickness: 1.2)),
        //     ],
        //   ),
        // ),
        TextButton(
          onPressed: isForgotLoading
              ? null
              : () async {
            setState(() => isForgotLoading = true);
            await handleForgotPassword();
            setState(() => isForgotLoading = false);
          },
          child: isForgotLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2),
          )
              : Column(
            children: const [
              Text('Forgot Password?', style: TextStyle(color: Colors.green, fontSize: 15)),
              SizedBox(height: 2),
              SizedBox(width: 130, child: Divider(color: Colors.white24, thickness: 1.2)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     const Text("Don't Have an Account?", style: TextStyle(color: Colors.white, fontSize: 15)),
        //     TextButton(
        //       onPressed: () => Navigator.pushNamed(context, 'register'),
        //       child: const Text('Sign Up', style: TextStyle(color: Colors.green, fontSize: 15)),
        //     ),
        //   ],
        // ),
        // SIGN UP ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't Have an Account?", style: TextStyle(color: Colors.white, fontSize: 15)),
            TextButton(
              onPressed: isSignUpLoading
                  ? null
                  : () async {
                setState(() => isSignUpLoading = true);
                // Simulate a delay if needed or just navigate
                await Future.delayed(const Duration(milliseconds: 300));
                setState(() => isSignUpLoading = false);
                Navigator.pushNamed(context, 'register');
              },
              child: isSignUpLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2),
              )
                  : const Text('Sign Up', style: TextStyle(color: Colors.green, fontSize: 15)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 8.0),
          child: Icon(icon, color: Colors.green, size: 18),
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
  Future<String> login(BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        // Uri.parse('https://admin-growup.onebitstore.site/api/investor/login'),
        Uri.parse(ApiConstants.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone_email': email,
          'password': password,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // If your response has a "data" wrapper, uncomment the next line and replace 'json' with 'data' below
        // final data = json['data'];

        // If no "data" wrapper, just use json directly:
        final data = json;
        final token = data['token'];
        final investor = data['user'];
        final prefs = await SharedPreferences.getInstance();

        // Save token and user info
        await prefs.setString('auth_token', token);
        await prefs.setString('investor_name', investor['name'] ?? '');
        await prefs.setString('investor_email', investor['email'] ?? '');
        await prefs.setString('investor_phone', investor['phone'] ?? '');
        await prefs.setString('investor_code', investor['investor_code'] ?? '');
        await prefs.setString('investor_id', investor['id'].toString());
        await prefs.setString('investor_image', investor['image'] ?? '');


        // Save dashboard info from the root level of response JSON (siblings of 'user')
        await prefs.setString('wallet_balance', data['wallet_balance']?.toString() ?? '0');
        await prefs.setString('total_transation', data['total_transation']?.toString() ?? '0');
        await prefs.setString('total_investment', data['total_investment']?.toString() ?? '0');
        await prefs.setString('total_income', data['total_income']?.toString() ?? '0'); // changed
        await prefs.setString('todays_income', data['todays_income']?.toString() ?? '0'); // changed
        await prefs.setString('total_projects', data['total_projects']?.toString() ?? '0'); // changed

        print("Investor ID: ${investor['id']}");
        print("Investor Name: ${investor['name']}");
        print("Investor Code: ${investor['investor_code']}");
        print("Token and investor info saved!");
        print("wallet_balance: ${data['wallet_balance']}");
        print("total_transation: ${data['total_transation']}");
        print("total_investment: ${data['total_investment']}");
        print("total_income: ${data['total_income']}");
        print("todays_income: ${data['todays_income']}");
        print("total_projects: ${data['total_projects']}");

        return token;
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Login failed';
        throw Exception(error);
      }
    } catch (e) {
      print("Login error: $e");
      throw Exception("An error occurred during login.");
    }
  }
}
