import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todays_income_dialog_model.dart';

class TodaysIncomeDialog extends StatefulWidget {
  const TodaysIncomeDialog({super.key});

  @override
  State<TodaysIncomeDialog> createState() => _TodaysIncomeDialogState();
}

class _TodaysIncomeDialogState extends State<TodaysIncomeDialog> {
  List<RoiDetail> roiList = [];
  List<RoiDetail> filteredList = [];
  bool isLoading = false;
  int currentPage = 1;
  final int rowsPerPage = 10;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchTodaysIncome();
  }

  Future<void> fetchTodaysIncome() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final investorCode = prefs.getString('investor_code') ?? '';

      final response = await http.get(
        Uri.parse('https://admin-growup.onebitstore.site/api/investor/pop-up/todays-income?investor_code=$investorCode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<RoiDetail> loadedRois = (jsonData['data']['roi_details'] as List)
            .map((e) => RoiDetail.fromJson(e))
            .toList();
        setState(() {
          roiList = loadedRois;
          filteredList = loadedRois;
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

  void _filterList(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      currentPage = 1;
      filteredList = roiList.where((item) {
        final projectName = item.projectName.toLowerCase();
        final formattedDate = _formatDate(item.createdAt).toLowerCase();
        return projectName.contains(searchQuery) || formattedDate.contains(searchQuery);
      }).toList();
    });
  }

  List<RoiDetail> get currentPageItems {
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

  String _formatDate(String raw) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return 'Invalid';
    }
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
          const Text('ROI Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Project Name or Date (e.g. 03 Aug 2025)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _filterList,
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
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Project Name')),
                      DataColumn(label: Text('ROI')),
                    ],
                    rows: List.generate(currentPageItems.length, (index) {
                      final item = currentPageItems[index];
                      return DataRow(cells: [
                        DataCell(Text('${(currentPage - 1) * rowsPerPage + index + 1}')),
                        DataCell(Text(_formatDate(item.createdAt))),
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

          // 📄 Pagination
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
