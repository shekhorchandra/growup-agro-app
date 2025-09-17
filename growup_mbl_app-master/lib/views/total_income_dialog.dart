import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/total_income_dialog_model.dart';

class TotalIncomeDialog extends StatefulWidget {
  const TotalIncomeDialog({super.key});

  @override
  State<TotalIncomeDialog> createState() => _TotalIncomeDialogState();
}

class _TotalIncomeDialogState extends State<TotalIncomeDialog> {
  List<totalRoiDetail> roiList = [];
  List<totalRoiDetail> filteredList = [];
  bool isLoading = false;
  int currentPage = 1;
  final int rowsPerPage = 10;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchTotalIncome();
  }

  Future<void> fetchTotalIncome() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final investorCode = prefs.getString('investor_code') ?? '';

      final response = await http.get(
        Uri.parse('https://admin-growup.onebitstore.site/api/investor/pop-up/total-income?investor_code=$investorCode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<totalRoiDetail> loadedRois = (jsonData['data']['roi_details'] as List)
            .map((e) => totalRoiDetail.fromJson(e))
            .toList();
        setState(() {
          roiList = loadedRois;
          filteredList = loadedRois; // Initialize filteredList
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<totalRoiDetail> get currentPageItems {
    final start = (currentPage - 1) * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredList.length);
    return filteredList.sublist(start, end);
  }

  void _nextPage() {
    if (currentPage * rowsPerPage < filteredList.length) {
      setState(() => currentPage++);
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
    }
  }

  void _search(String query) {
    setState(() {
      searchQuery = query;
      currentPage = 1;
      filteredList = roiList
          .where((roi) => roi.projectName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.8,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 12),
          const Text('Total Income', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Project Name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _search,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: DataTable(
                    columnSpacing: 32,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF388E3C)),
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    columns: const [
                      DataColumn(label: Text('SL')),
                      DataColumn(label: Text('Project Name')),
                      DataColumn(label: Text('ROI')),
                    ],
                    rows: List.generate(currentPageItems.length, (index) {
                      final item = currentPageItems[index];
                      return DataRow(cells: [
                        DataCell(Text('${(currentPage - 1) * rowsPerPage + index + 1}')),
                        DataCell(Text(item.projectName)),
                        DataCell(Text('৳${item.totalRoi.toStringAsFixed(2)}')),
                      ]);
                    }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _previousPage, child: const Text('Previous')),
              const SizedBox(width: 16),
              Text('Page $currentPage of ${(filteredList.length / rowsPerPage).ceil()}'),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: _nextPage, child: const Text('Next')),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
