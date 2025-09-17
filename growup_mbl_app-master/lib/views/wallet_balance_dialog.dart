
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:growup_agro/models/wallet_history_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletHistoryDialog extends StatefulWidget {
  const WalletHistoryDialog({super.key});

  @override
  State<WalletHistoryDialog> createState() => _WalletHistoryDialogState();
}

class _WalletHistoryDialogState extends State<WalletHistoryDialog> {
  List<WalletHistoryModel> fullHistory = [];
  List<WalletHistoryModel> filteredHistory = [];
  Set<String> downloadingInvoices = {};
  final int rowsPerPage = 10;

  int currentPage = 1;
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWalletHistory();
    _searchController.addListener(() {
      _filterHistory(_searchController.text);
    });
  }

  Future<void> _fetchWalletHistory() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final investorCode = prefs.getString('investor_code') ?? '';

      final response = await http.get(
        Uri.parse('https://admin-growup.onebitstore.site/api/wallet-history?investor_code=$investorCode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final historyList = data.map<WalletHistoryModel>((e) => WalletHistoryModel.fromJson(e)).toList();
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
      return item.trxId.toLowerCase().contains(lower) ||
          item.type.toLowerCase().contains(lower);
    }).toList();

    setState(() {
      filteredHistory = result;
      currentPage = 1;
    });
  }

  List<WalletHistoryModel> get currentPageItems {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return filteredHistory.sublist(start, end > filteredHistory.length ? filteredHistory.length : end);
  }

  // Future<void> _downloadInvoiceToDownloads(BuildContext context, String invoiceNo) async {
  //   setState(() => downloadingInvoices.add(invoiceNo));
  //   final dio = Dio();
  //   final url = 'https://admin-growup.onebitstore.site/api/invoice/pdf/$invoiceNo';
  //
  //   try {
  //     if (Platform.isAndroid) {
  //       final perm = await [
  //         Permission.storage,
  //         Permission.manageExternalStorage
  //       ].request();
  //       if (!perm.values.every((status) => status.isGranted)) {
  //         throw Exception('Permission denied');
  //       }
  //     }
  //
  //     final dir = Directory('/storage/emulated/0/Download/Growup');
  //     if (!await dir.exists()) await dir.create(recursive: true);
  //     final path = '${dir.path}/invoice_$invoiceNo.pdf';
  //
  //     await dio.download(url, path);
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded to $path'), backgroundColor: Colors.green));
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
  //   } finally {
  //     setState(() => downloadingInvoices.remove(invoiceNo));
  //   }
  // }

  Widget _getStatusChip(String? status) {
    final s = status?.toLowerCase() ?? 'n/a';
    final map = {
      'approved': Colors.green,
      'rejected': Colors.red,
      'pending': Colors.orange,
      'completed': Colors.grey,
    };
    final color = map[s] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(status ?? 'N/A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  String _formatDateTime(String raw) {
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(raw));
    } catch (_) {
      return 'Invalid';
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
          const Text('Total Wallet Balance History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Transaction ID or Type',
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
                      DataColumn(label: Text('Transaction Info')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Status')),
                      //DataColumn(label: Text('Note')),
                      //DataColumn(label: Text('Invoice')),
                    ],
                    rows: List.generate(currentPageItems.length, (index) {
                      final item = currentPageItems[index];
                      return DataRow(cells: [
                        DataCell(Text('${(currentPage - 1) * rowsPerPage + index + 1}')),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ID: ${item.trxId}', style: const TextStyle(fontSize: 12)),
                            Text('Type: ${item.type}', style: const TextStyle(fontSize: 12)),
                            Text(_formatDateTime(item.createdAt), style: const TextStyle(fontSize: 12)),
                          ],
                        )),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Direction: ${item.direction == 'in' ? 'Credit' : 'Debit'}', style: const TextStyle(fontSize: 12)),
                            Text('৳${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                          ],
                        )),
                        DataCell(_getStatusChip(item.status)),
                        //DataCell(Text(item.note ?? 'N/A')),
                        // DataCell(item.invoiceNo != 0
                        //     ? (downloadingInvoices.contains(item.invoiceNo.toString())
                        //     ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        //     : IconButton(
                        //   icon: const Icon(Icons.download, color: Colors.green),
                        //   onPressed: () => _downloadInvoiceToDownloads(context, item.invoiceNo.toString()),
                        // ))
                        //     : const Text('N/A')),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Red background
            ),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.white), // White text
            ),
          ),

        ],
      ),
    );
  }
}
