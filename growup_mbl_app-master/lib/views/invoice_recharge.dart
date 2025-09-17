import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recharge_model.dart';

class InvoiceRechargePage extends StatefulWidget {
  const InvoiceRechargePage({super.key});

  @override
  State<InvoiceRechargePage> createState() => _InvoiceRechargePageState();
}

class _InvoiceRechargePageState extends State<InvoiceRechargePage> {
  late Future<List<Recharge>> futureRecharges;

  List<Recharge> fullList = [];
  List<Recharge> filteredList = [];
  int currentPage = 1;
  final int rowsPerPage = 10;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureRecharges = fetchRecharges();
    _searchController.addListener(() {
      _filterList(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList(String query) {
    final filtered = fullList.where((item) {
      final date = item.date.toLowerCase();
      final amount = item.amount.toLowerCase();
      final method = item.method.toLowerCase();
      final status = item.status.toLowerCase();
      final note = item.note.toLowerCase();
      return date.contains(query.toLowerCase()) ||
          amount.contains(query.toLowerCase()) ||
          method.contains(query.toLowerCase()) ||
          status.contains(query.toLowerCase()) ||
          note.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredList = filtered;
      currentPage = 1;
    });
  }

  List<Recharge> get currentPageItems {
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex = (startIndex + rowsPerPage) > filteredList.length
        ? filteredList.length
        : (startIndex + rowsPerPage);
    return filteredList.sublist(startIndex, endIndex);
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

  Future<List<Recharge>> fetchRecharges() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final investorCode = prefs.getString('investor_code') ?? '';

    final url = Uri.parse(
        'https://admin-growup.onebitstore.site/api/recharges?investor_code=$investorCode');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == "success") {
          final List<dynamic> list = data['recharges'];
          return list.map((e) => Recharge.fromJson(e)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching recharges: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recharge History',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: FutureBuilder<List<Recharge>>(
        future: futureRecharges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No recharge found."));
          }

          if (fullList.isEmpty) {
            fullList = snapshot.data!;
            filteredList = fullList;
          }

          return Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Table
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Card(
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: DataTable(
                        columnSpacing: 28,
                        dataRowHeight: 60,
                        headingRowHeight: 60,
                        headingRowColor: MaterialStateProperty.all(
                            const Color(0xFF388E3C)),
                        headingTextStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        columns: const [
                          DataColumn(label: Text('SL')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Method')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Note')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: currentPageItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final slNumber =
                              ((currentPage - 1) * rowsPerPage) + index + 1;

                          return DataRow(cells: [
                            DataCell(Text('$slNumber')),
                            DataCell(Text(item.date)),
                            DataCell(Text(item.amount)),
                            DataCell(Text(item.method)),
                            DataCell(Text(item.status)),
                            DataCell(Text(item.note)),
                            DataCell(const Text('-')), // Action empty
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),

              // Pagination
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: currentPage > 1 ? _previousPage : null,
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Page $currentPage of ${(filteredList.length / rowsPerPage).ceil()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed:
                      currentPage * rowsPerPage < filteredList.length
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
