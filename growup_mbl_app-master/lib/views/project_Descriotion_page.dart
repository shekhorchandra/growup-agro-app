import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shurjopay/models/config.dart';
import 'package:shurjopay/models/shurjopay_request_model.dart';
import 'package:shurjopay/shurjopay.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:shurjopay_sdk/shurjopay_sdk.dart';
import 'package:get/get.dart'; // for Get.context
import 'package:shurjopay/shurjopay.dart';

import '../models/project_details_model.dart';

class ProjectDescriptionPage extends StatefulWidget {
  final int projectId;
  final String investorCode;

  const ProjectDescriptionPage({
    Key? key,
    required this.projectId,
    required this.investorCode,
  }) : super(key: key);

  @override
  State<ProjectDescriptionPage> createState() => _ProjectDescriptionPageState();
}

class _ProjectDescriptionPageState extends State<ProjectDescriptionPage> {
  ProjectDetailsModel? _project;
  bool _loading = true;
  bool _isInvestLoading = false;
  bool _isShurjoLoading = false;



  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300) {
        if (!_showScrollToTopButton) {
          setState(() {
            _showScrollToTopButton = true;
          });
        }
      } else {
        if (_showScrollToTopButton) {
          setState(() {
            _showScrollToTopButton = false;
          });
        }
      }
    });
    _fetchProjectDetails();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<int> _fetchLatestWalletBalance(String token, String investorCode) async {
    try {
      // final url = Uri.parse('https://admin-growup.onebitstore.site/api/investor/profile?investor_code=$investorCode');
      final url = Uri.parse(ApiConstants.investorProfile(investorCode));
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final balanceStr = data['data']?['investor']?['wallet']?['balance']?.toString().replaceAll(',', '') ?? '0';
        return double.tryParse(balanceStr)?.toInt() ?? 0;
      } else {
        throw Exception("Failed to fetch wallet balance");
      }
    } catch (e) {
      debugPrint("Error fetching wallet balance: $e");
      return 0; // fallback
    }
  }

  Future<void> _fetchProjectDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    // final url = Uri.parse(
    //   'https://admin-growup.onebitstore.site/api/investor/project-details'
    //       '?investor_code=${widget.investorCode}&project_id=${widget.projectId}',
    // );
    final url = Uri.parse(
      ApiConstants.investorProjectDetails(
        widget.investorCode,
        widget.projectId.toString(), // ✅ convert int → String
      ),
    );


    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _project = ProjectDetailsModel.fromJson(data);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to load project details')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = _project;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details', style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white),),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : project == null
          ? const Center(child: Text('Project data not available'))
          : SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  project.imageUrl!,
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
                ),
              ),
            const SizedBox(height: 16),
            Text(project.projectName ?? 'No Title',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Category: ${project.projectCategoryName ?? 'N/A'}"),
            Text("Project Code: ${project.projectCode ?? 'N/A'}"),
            const Divider(height: 30),
            const Text("Project Overview:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Html(data: project.overviewHtml ?? ''),
            const SizedBox(height: 20),
            _buildKeyPointsCard(project),
            if (project.securityInformation.isNotEmpty) _buildSecurityCard(project),
            const SizedBox(height: 24),
            _buildSummaryCard(project),
          ],
        ),
      ),
      floatingActionButton: _showScrollToTopButton
          ? FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        child: const Icon(Icons.arrow_upward, color: Colors.white,),
      )
          : null,
    );
  }

  Widget _buildKeyPointsCard(ProjectDetailsModel project) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Key Points", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            InfoRow(title: "Duration", value: _getKeyPoint("Duration of Investment")),
            InfoRow(title: "Projected ROI", value: _getKeyPoint("Projected ROI (Return on Investment)")),
            InfoRow(title: "Risk Factor", value: _getKeyPoint("Risk Factor")),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(ProjectDetailsModel project) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Project Security Information",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...project.securityInformation.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(item['name'] ?? '')),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ProjectDetailsModel project) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Project Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            InfoRow(title: "Project Name", value: project.projectName),
            InfoRow(title: "Business Type", value: project.businessTypeName),
            InfoRow(
              title: "Investment Time",
              value: "${project.investment_time.toString()} days",
            ),

            InfoRow(title: "Investment Goal", value: project.investmentGoal),
            InfoRow(
              title: "Min Investment",
              value: NumberFormat.decimalPattern().format(project.minInvestmentAmount ?? 0),
            ),
            InfoRow(
              title: "In Waiting",
              value: NumberFormat.decimalPattern().format(project.in_waiting),
            ),
            InfoRow(
              title: "Raised",
              value: NumberFormat.decimalPattern().format(project.rasied),
            ),
            InfoRow(title: "Projected", value: project.projected),
            InfoRow(
              title: "ROI (%)",
              value: "Annually ${double.tryParse(project.annualRoi)?.toStringAsFixed(2) ?? project.annualRoi}%",
            ),
            InfoRow(title: "Duration", value: project.projectDurationViewer),
            InfoRow(title: "ROI Start Date", value: project.roiStartDate),
            InfoRow(
              title: "Project Status",
              value: project.status == 1 ? 'Running' : 'Closed',
              style: TextStyle(
                color: project.status == 1 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (project.status == 1 && project.investment_time > 0)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isInvestLoading || _isShurjoLoading
                          ? null // Disable if either is loading to avoid multiple simultaneous taps
                          : () async {
                        setState(() => _isInvestLoading = true);
                        await _triggerInvestDialog();
                        if (mounted) setState(() => _isInvestLoading = false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAECC00)),
                      child: _isInvestLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Invest Now',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isInvestLoading || _isShurjoLoading
                          ? null
                          : () async {
                        setState(() => _isShurjoLoading = true);
                        await _triggerShurjoInvestDialog();
                        if (mounted) setState(() => _isShurjoLoading = false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: _isShurjoLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Pay with ShurjoPay',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )
            else
              const SizedBox.shrink(), // or show a message like: "This project is closed or expired."

          ],
        ),
      ),
    );
  }

  Future<void> _triggerShurjoInvestDialog() async {
    final resData = await _showInvestDialog(isShurjoPay: true); // ✅ MARKED: Added isShurjoPay

    if (resData == null) return;

    if (resData['success'] == true ||
        (resData['message']?.toString().toLowerCase().contains('success') ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Congratulations! Payment successful!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resData['message'] ?? 'Payment failed.'), backgroundColor: Colors.red),
      );
    }
  }


  Future<void> _triggerInvestDialog() async {
    final resData = await _showInvestDialog();

    if (resData == null) return; // dialog cancelled

    if (resData['success'] == true ||
        (resData['message']?.toString().toLowerCase().contains('success') ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Congratulation! Investment successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resData['message'] ?? 'Investment failed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _showInvestDialog({bool isShurjoPay = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final investorCode = prefs.getString('investor_code');
    final investorId = prefs.getString('investor_id');
    final email = prefs.getString('investor_email') ?? 'default@email.com';

    if (token == null || investorId == null || investorCode == null || _project == null) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing data or login required.")),
      );
      return null;
    }

    final walletBalance = await _fetchLatestWalletBalance(token, investorCode);
    final project = _project!;
    final outerContext = context;

    Future<String> _getPublicIP() async {
      try {
        final res = await http.get(Uri.parse('https://api.ipify.org'));
        return res.body;
      } catch (e) {
        return '127.0.0.1'; // fallback IP
      }
    }

    return showDialog<Map<String, dynamic>>(
      context: outerContext,
      builder: (dialogContext) {
        bool _isLoading = false;

        Future<bool> verifyShurjoPayPayment(String spToken, String orderId) async {
          try {
            final response = await http.post(
              Uri.parse('https://sandbox.shurjopayment.com/api/verification'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $spToken',
              },
              body: jsonEncode({'order_id': orderId}),
            );

            if (response.statusCode == 200) {
              final List<dynamic> resData = jsonDecode(response.body);
              if (resData.isNotEmpty) {
                final payment = resData[0];
                final transactionStatus = (payment['transaction_status'] ?? '').toString().toLowerCase();
                final spCode = payment['sp_code']?.toString() ?? '';

                return transactionStatus == 'completed' || spCode == '1000' || spCode == '200';
              }
            }
            return false;
          } catch (e) {
            debugPrint('Error verifying payment: $e');
            return false;
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            final amountController = TextEditingController(
              text: project.minInvestmentAmount?.toString() ?? '0',
            );

            void disposeController() {
              amountController.dispose();
            }

            return WillPopScope(
              onWillPop: () async {
                disposeController();
                return true;
              },
              child: AlertDialog(
                title: const Text("Invest in this Project"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Wallet Balance: ৳$walletBalance"),
                      Text("Min. Investment: ৳${project.minInvestmentAmount}"),
                      Text("In Waiting: ৳${project.in_waiting}"),
                      Text("Investment Time: ${project.investment_time} days"),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        enabled: !_isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Invest Amount',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      disposeController();
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: _isLoading
                        ? null
                        : () async {
                      setState(() {
                        _isLoading = true;
                      });

                      final amount = int.tryParse(amountController.text);

                      if (amount == null || amount <= 0) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          const SnackBar(content: Text("Enter a valid investment amount.")),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }

                      if (amount < (project.minInvestmentAmount ?? 0)) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          SnackBar(
                            content: Text("Invest amount must be at least ৳${project.minInvestmentAmount}"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }

                      if (project.investment_time < 1) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          const SnackBar(
                            content: Text("You can't invest. Investment time is too short."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }

                      if ((project.minInvestmentAmount ?? 0) > project.in_waiting) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          const SnackBar(
                            content: Text("You can't invest. In Waiting amount too low."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }

                      if (!isShurjoPay && walletBalance < amount) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          const SnackBar(
                            content: Text("Insufficient wallet balance. Please recharge."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }

                      if (project.status != 1) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          const SnackBar(
                            content: Text("Project is not running."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        return;
                      }

                      if (isShurjoPay) {
                        try {
                          final tokenRes = await http.post(
                            Uri.parse('https://sandbox.shurjopayment.com/api/get_token'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Accept': 'application/json',
                            },
                            body: jsonEncode({
                              'username': 'sp_sandbox',
                              'password': 'pyyk97hu&6u6',
                            }),
                          );

                          if (tokenRes.statusCode != 200) throw Exception('Failed to get token');

                          final tokenData = jsonDecode(tokenRes.body);
                          final spToken = tokenData['token'];
                          final storeId = tokenData['store_id'].toString();

                          final orderId = 'growup_${DateTime.now().millisecondsSinceEpoch}';
                          final clientIp = await _getPublicIP();

                          final payRes = await http.post(
                            Uri.parse('https://sandbox.shurjopayment.com/api/secret-pay'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Accept': 'application/json',
                              'Authorization': 'Bearer $spToken',
                            },
                            body: jsonEncode({
                              "prefix": "sp",
                              "token": spToken,
                              "return_url": "https://admin-growup.onebitstore.site/api/shurjopay/payment/callback",
                              "cancel_url": "https://sandbox.shurjopayment.com/response",
                              "store_id": storeId,
                              "amount": amount,
                              "order_id": orderId,
                              "currency": "BDT",
                              "customer_name": "GrowUp Investor",
                              "customer_address": "Dhaka, Bangladesh",
                              "customer_email": email,
                              "customer_phone": "+8801700000000",
                              "customer_city": "Dhaka",
                              "customer_post_code": "1200",
                              "client_ip": clientIp,
                              "value1": investorId,               // Raw investor_code
                              "value2": widget.projectId.toString(), // Raw project ID
                              "value3": "project_investment",       // transaction type expected by backend
                              "value4": "",                         // optional/empty
                            }),
                          );

                          if (payRes.statusCode != 200) {
                            throw Exception('Payment initiation failed with status ${payRes.statusCode}');
                          }

                          final payData = jsonDecode(payRes.body);
                          final checkoutUrl = payData['checkout_url'];

                          if (checkoutUrl != null && checkoutUrl.toString().startsWith('http')) {
                            final launched = await launchUrl(
                              Uri.parse(checkoutUrl),
                              mode: LaunchMode.externalApplication,
                            );

                            if (!launched) {
                              throw Exception('Could not launch payment URL');
                            }

                            disposeController();

// ✅ Show a message like:
                            ScaffoldMessenger.of(outerContext).showSnackBar(
                              const SnackBar(
                                content: Text('Please complete your payment in browser and come back.'),
                                backgroundColor: Colors.blue,
                              ),
                            );

                          } else {
                            final message = payData['message'] ?? 'Unknown error';
                            throw Exception('Payment failed: $message');
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(outerContext).showSnackBar(
                            SnackBar(content: Text('❌ Payment failed: $e')),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      }
                      else {
                        // Wallet payment flow (unchanged)
                        try {
                          final response = await http.post(
                            Uri.parse('https://admin-growup.onebitstore.site/api/investor/invest-now'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                            body: jsonEncode({
                              'project_id': widget.projectId,
                              'invest_amount': amount,
                              'investment_media': 1,
                              'investor_code': investorCode,
                            }),
                          );

                          final resData = jsonDecode(response.body);
                          if (!mounted) return;

                          if (resData['success'] == true) {
                            disposeController();
                            Navigator.pop(dialogContext, resData);
                            ScaffoldMessenger.of(outerContext).showSnackBar(
                              const SnackBar(
                                content: Text('Investment successful!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(outerContext).showSnackBar(
                              SnackBar(
                                content: Text(resData['message'] ?? 'Investment failed'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(outerContext).showSnackBar(
                            SnackBar(content: Text('❌ Investment failed: $e')),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      }
                    },
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(isShurjoPay ? "PAY NOW" : "INVEST",
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getKeyPoint(String title) {
    final project = _project;
    if (project == null) return 'Not available';

    final match = project.keyPointsData.firstWhere(
          (point) => point['title']?.toString().trim().toLowerCase() == title.trim().toLowerCase(),
      orElse: () => {},
    );

    return match['description'] ?? 'Not available';
  }
}

class InfoRow extends StatelessWidget {
  final String title;
  final String? value;
  final TextStyle? style;

  const InfoRow({
    super.key,
    required this.title,
    required this.value,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: Text("$title:", style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 6, child: Text(value ?? "N/A", softWrap: true, style: style ?? const TextStyle())),
        ],
      ),
    );
  }
}

