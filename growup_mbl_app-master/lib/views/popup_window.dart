import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InvestNowButton extends StatelessWidget {
  final int projectId;
  final String investorCode;

  const InvestNowButton({
    Key? key,
    required this.projectId,
    required this.investorCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showInvestPopup(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFAECC00),
      ),
      child: const Text(
        'Invest Now',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _showInvestPopup(BuildContext context) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Invest in Project"),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Invest Amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  Navigator.of(context).pop();

                  // Delay to let the dialog close before showing SnackBar
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _showSnackBar(
                      context,
                      "Processing investment...",
                      bgColor: Colors.blue,
                    );
                  });

                  _investNow(context, amount);
                } else {
                  _showSnackBar(
                    context,
                    "Enter a valid amount",
                    bgColor: Colors.red,
                  );
                }
              },
              child: const Text("INVEST"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _investNow(BuildContext context, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      _showSnackBar(context, "Authentication token not found", bgColor: Colors.red);
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final url = Uri.parse('https://admin-growup.onebitstore.site/api/investor/invest-now');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'project_id': projectId,
        'invest_amount': amount,
        'investment_media': 1,
        'investor_code': investorCode,
      }),
    );

    // Close loading dialog
    Navigator.of(context).pop();

    if (response.statusCode == 201) {
      _showSnackBar(
        context,
        "Investment successful. Thank you for your investment!",
        bgColor: Colors.green,
      );
    } else {
      _showSnackBar(
        context,
        "Investment failed. Please try again.",
        bgColor: Colors.red,
      );
    }
  }

  void _showSnackBar(BuildContext context, String message, {Color? bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
