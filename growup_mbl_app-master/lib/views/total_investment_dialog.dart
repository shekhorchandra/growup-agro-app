import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growup_agro/models/investment_history_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TotalInvestmentHistoryPage extends StatefulWidget {
  const TotalInvestmentHistoryPage({super.key});

  @override
  State<TotalInvestmentHistoryPage> createState() => _TotalInvestmentHistoryPageState();
}

class _TotalInvestmentHistoryPageState extends State<TotalInvestmentHistoryPage> {
  List<InvestmentHistoryItem> fullHistory = [];
  List<InvestmentHistoryItem> filteredHistory = [];
  int currentPage = 1;
  final int rowsPerPage = 10;
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '৳');

  @override
  void initState() {
    super.initState();
    _fetchInvestmentHistory();
    _searchController.addListener(() {
      _filterHistory(_searchController.text);
    });
  }

  Future<void> _fetchInvestmentHistory() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final investorCode = prefs.getString('investor_code') ?? '';

      final url = Uri.parse('https://admin-growup.onebitstore.site/api/investment-history?investor_code=$investorCode');
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final historyList = data.map<InvestmentHistoryItem>((e) => InvestmentHistoryItem.fromJson(e)).toList();
        setState(() {
          fullHistory = historyList;
          filteredHistory = fullHistory;
        });
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterHistory(String query) {
    final lower = query.toLowerCase();
    final result = fullHistory.where((item) {
      return (item.projectTitle?.toLowerCase() ?? '').contains(lower) ||
          (item.projectCategory?.toLowerCase() ?? '').contains(lower);
    }).toList();

    setState(() {
      filteredHistory = result;
      currentPage = 1;
    });
  }

  List<InvestmentHistoryItem> get currentPageItems {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return filteredHistory.sublist(start, end > filteredHistory.length ? filteredHistory.length : end);
  }

  String _formatDate(String? raw) {
    if (raw == null) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  void _nextPage() {
    if (currentPage * rowsPerPage < filteredHistory.length) {
      setState(() => currentPage++);
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
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
          const Text('Total Investment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Project or Category',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: DataTable(
                    columnSpacing: 24,
                    dataRowHeight: 72,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF388E3C)),
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    columns: const [
                      DataColumn(label: Text('SL')),
                      DataColumn(label: Text('Project')),
                      DataColumn(label: Text('Investment Info')),
                    ],
                    rows: List.generate(currentPageItems.length, (index) {
                      final item = currentPageItems[index];
                      final sl = ((currentPage - 1) * rowsPerPage) + index + 1;
                      return DataRow(cells: [
                        DataCell(Text('$sl')),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Project: ${item.projectTitle ?? 'N/A'}', style: const TextStyle(fontSize: 12, )),
                            Text('Category: ${item.projectCategory ?? 'N/A'}', style: const TextStyle(fontSize: 12,)),
                          ],
                        )),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('৳${(item.totalInvestment ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                            Text('Date: ${_formatDate(item.firstInvestmentDate)}', style: const TextStyle(fontSize: 12)),
                          ],
                        )),
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
              Text('Page $currentPage of ${(filteredHistory.length / rowsPerPage).ceil()}'),
              const SizedBox(width: 16),
              ElevatedButton(onPressed: _nextPage, child: const Text('Next')),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
