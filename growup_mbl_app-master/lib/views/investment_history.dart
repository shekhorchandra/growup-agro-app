import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:growup_agro/views/investment_detail_page.dart';
import 'package:growup_agro/views/roi_details_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/investment_history_model.dart';

class InvestmentHistoryPage extends StatefulWidget {
  const InvestmentHistoryPage({super.key});

  @override
  State<InvestmentHistoryPage> createState() => _InvestmentHistoryPageState();
}

class _InvestmentHistoryPageState extends State<InvestmentHistoryPage> {
  late Future<List<InvestmentHistoryItem>> futureHistory;

  List<InvestmentHistoryItem> fullHistory = [];
  List<InvestmentHistoryItem> filteredHistory = [];
  int currentPage = 1;
  int itemsPerPage = 10; // or whatever number of items you show per page
  final int rowsPerPage = 10;
  String? investorCode;

  final TextEditingController _searchController = TextEditingController();

  final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '৳');

  @override
  void initState() {
    super.initState();
    futureHistory = fetchInvestmentHistory();
    _initialize();
    _searchController.addListener(() {
      _filterHistory(_searchController.text);
    });
  }

  String formatDate(String? rawDate) {
    if (rawDate == null) return 'N/A';
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy').format(date); // e.g., 16 Jul 2025, 02:30 PM
    } catch (e) {
      return rawDate;
    }
  }


  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    investorCode = prefs.getString('investor_code');
    setState(() {}); // Update UI with investorCode
    futureHistory = fetchInvestmentHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterHistory(String query) {
    final filtered = fullHistory.where((item) {
      final title = item.projectTitle?.toLowerCase() ?? '';
      final category = item.projectCategory?.toLowerCase() ?? '';
      return title.contains(query.toLowerCase()) ||
          category.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredHistory = filtered;
      currentPage = 1; // Reset to first page on search
    });
  }

  List<InvestmentHistoryItem> get currentPageItems {
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex = (startIndex + rowsPerPage) > filteredHistory.length
        ? filteredHistory.length
        : (startIndex + rowsPerPage);
    return filteredHistory.sublist(startIndex, endIndex);
  }

  void _nextPage() {
    if (currentPage * rowsPerPage < filteredHistory.length) {
      setState(() {
        currentPage++;
      });
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  Future<List<InvestmentHistoryItem>> fetchInvestmentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final investorCode = prefs.getString('investor_code') ?? '';

    if (token.isEmpty || investorCode.isEmpty) {
      throw Exception("Missing token or investor code. Please log in again.");
    }
    final url = Uri.parse(ApiConstants.investmentHistory(investorCode));

    // final url = Uri.parse(
    //   'https://admin-growup.onebitstore.site/api/investment-history?investor_code=$investorCode',
    // );

    print("Calling URL: $url");
    print("Token used: $token");

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json',
        'Authorization': 'Bearer $token'},
    );

    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List data = body['data'];
      return data.map((e) => InvestmentHistoryItem.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Unknown error'}',
      );
    }
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Investment History',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true, // <-- This centers the title on all phones
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,// or your preferred color
      ),

      body: FutureBuilder<List<InvestmentHistoryItem>>(
        future: futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No investment history found."));
          }

          if (fullHistory.isEmpty) {
            fullHistory = snapshot.data!;
            filteredHistory = fullHistory;
          }

          return Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by project or category',
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
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Card(
                      child: DataTable(
                        columnSpacing: 24,
                        dataRowHeight: 100,
                        headingRowHeight: 60,
                        headingRowColor: MaterialStateProperty.all(
                          const Color(0xFF388E3C),
                        ),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        columns: const [
                          DataColumn(label: Text('SL')),
                          DataColumn(label: Text('Project')),
                          DataColumn(label: Text('Investment')),
                          DataColumn(label: Text('ROI')),
                          DataColumn(label: Text('Capital Return')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: currentPageItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          final roiAmount = item.roiDetails ?? 0;
                          final capitalReturnAmount = item.capitalReturnDetails ?? 0;

                          // Pagination-aware SL
                          final slNumber = ((currentPage - 1) * itemsPerPage) + index + 1;

                          return DataRow(
                            cells: [
                              DataCell(Text('$slNumber')), // SL column with pagination
                              DataCell(
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: (item.projectImage != null && item.projectImage!.isNotEmpty)
                                          ? Image.network(
                                        '${ApiConstants.imgBaseUrl}${item.projectImage}',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 50),
                                      )
                                          : const Icon(Icons.broken_image, size: 50),

                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.projectTitle ?? 'N/A',
                                          style: const TextStyle(fontSize: 14, color: Colors.black),
                                        ),
                                        Text(
                                          "Category: ${item.projectCategory ?? 'N/A'}",
                                          style: const TextStyle(fontSize: 10, color: Colors.black),
                                        ),
                                        Text(
                                          "Project ID: ${item.project_id.toString()}",
                                          style: const TextStyle(fontSize: 10, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(currencyFormatter.format(item.totalInvestment ?? 0)),
                                    Text(
                                      formatDate(item.firstInvestmentDate),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                              DataCell(Text(currencyFormatter.format(roiAmount))),
                              DataCell(Text(currencyFormatter.format(capitalReturnAmount))),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item.status),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: ((item.projectProgress ?? 0) / 100).clamp(0.0, 1.0),
                                      backgroundColor: Colors.grey[300],
                                      color: _getProgressColor(item.projectProgress ?? 0),
                                      minHeight: 6,
                                    ),
                                    const SizedBox(height: 2),
                                    Text('${(item.projectProgress ?? 0).toStringAsFixed(2)}%'),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Tooltip(
                                      message: 'View All Investments',
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProjectInvestmentDetailPage(
                                                projectId: item.project_id,
                                                projectTitle: item.projectTitle ?? 'N/A',
                                                projectCategory: item.projectCategory ?? 'N/A',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'View All Investments',
                                          style: TextStyle(fontSize: 12, color: Colors.green),
                                        ),
                                      ),
                                    ),
                                    if (investorCode != null)
                                      Tooltip(
                                        message: 'View Total ROI Details',
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => RoiDetailsPage(
                                                  investorCode: investorCode!,
                                                  projectId: item.project_id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'View Total ROI Details',
                                            style: TextStyle(fontSize: 12, color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),


                      ),
                    ),
                  ),
                ),
              ),

              // Pagination at bottom center
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: currentPage > 1 ? _previousPage : null,
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Page $currentPage of ${(filteredHistory.length / rowsPerPage).ceil()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed:
                      currentPage * rowsPerPage < filteredHistory.length
                          ? _nextPage
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
