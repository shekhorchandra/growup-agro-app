import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:growup_agro/models/wallet_history_model.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WalletHistoryPage extends StatefulWidget {
  const WalletHistoryPage({super.key});

  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  List<WalletHistoryModel> fullHistory = [];
  List<WalletHistoryModel> filteredHistory = [];
  Set<String> downloadingInvoices = {};

  int _selectedIndex = 0;
  final List<Widget> _pages = [
    // MenuPage(),       // index 0
    // GrowupPage(),     // index 1
    // PropertyPage(),   // index 2
    // TradingPage(),    // index 3
    // WebTabPage(),     // index 4 <-- this shows your WebView
  ];
  int currentPage = 1;
  final int rowsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;

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

      if (token.isEmpty || investorCode.isEmpty) {
        throw Exception("Missing token or investor code");
      }

      // final response = await http.get(
      //   Uri.parse(
      //       'https://admin-growup.onebitstore.site/api/wallet-history?investor_code=$investorCode'),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //     'Accept': 'application/json',
      //   },
      // );
      final response = await http.get(
        Uri.parse(ApiConstants.walletHistory(investorCode)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List data = body['data'];
        final historyList =
        data.map((e) => WalletHistoryModel.fromJson(e)).toList();

        setState(() {
          fullHistory = historyList;
          filteredHistory = fullHistory;
          currentPage = 1;
        });
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${json.decode(response.body)['message']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterHistory(String query) {
    final filtered = fullHistory.where((item) {
      final trxId = item.trxId.toLowerCase();
      final type = item.type.toLowerCase();
      return trxId.contains(query.toLowerCase()) ||
          type.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredHistory = filtered;
      currentPage = 1;
    });
  }

  List<WalletHistoryModel> get currentPageItems {
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex = (startIndex + rowsPerPage > filteredHistory.length)
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

  String _formatDateTime(String rawDateTime) {
    try {
      final dateTime = DateTime.parse(rawDateTime);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _downloadInvoiceToDownloads(
      BuildContext context, String invoiceNo) async {
    setState(() {
      downloadingInvoices.add(invoiceNo);
    });

    final dio = Dio();
    //final url = 'https://admin-growup.onebitstore.site/api/invoice/pdf/$invoiceNo';

    try {
      // ✅ Get auth token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token missing. Please log in again.'),
          ),
        );
        return;
      }

      // ✅ Get app-specific directory (sandboxed, no storage permission needed)
      Directory downloadsDir;
      if (Platform.isAndroid || Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = Directory.systemTemp;
      }

      final filePath = '${downloadsDir.path}/invoice_$invoiceNo.pdf';

      final url = ApiConstants.invoicePdf(invoiceNo);
      // ✅ Download invoice
      await dio.download(
        url,
        filePath,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/pdf",
          },
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
                'Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // ✅ Open the downloaded PDF
      await OpenFile.open(filePath);

      // ✅ Optionally share via snackbar action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice downloaded and opened successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        downloadingInvoices.remove(invoiceNo);
      });
    }
  }


  ///  Custom Status Chip
  Widget _getStatusChip(String? status) {
    if (status == null) return const Text('N/A');

    final lowerStatus = status.toLowerCase();
    late Color backgroundColor;
    late Color textColor;

    switch (lowerStatus) {
      case 'approved':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'rejected':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case 'pending':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'completed':
        backgroundColor = Colors.grey.shade300;
        textColor = Colors.black;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet History',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),

      body: RefreshIndicator(
        onRefresh: _fetchWalletHistory,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by Transaction ID or Type',
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
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Card(
                      child: DataTable(
                        columnSpacing: 24,
                        dataRowHeight: 72,
                        headingRowColor: MaterialStateProperty.all(
                            const Color(0xFF388E3C)),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        columns: const [
                          DataColumn(label: Text('SL')),
                          DataColumn(label: Text('Transaction Info')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actioned By')),
                          DataColumn(label: Text('Note')),
                          DataColumn(label: Text('Invoice')),
                        ],
                        rows: List.generate(currentPageItems.length,
                                (index) {
                              final item = currentPageItems[index];
                              return DataRow(cells: [
                                DataCell(Text(
                                    '${(currentPage - 1) * rowsPerPage + index + 1}')),
                                DataCell(Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text('Transaction ID: ${item.trxId}',
                                        style:
                                        const TextStyle(fontSize: 12)),
                                    Text('Transaction Type: ${item.type}',
                                        style:
                                        const TextStyle(fontSize: 12)),
                                    Text(
                                        'Date & Time: ${_formatDateTime(item.createdAt)}',
                                        style:
                                        const TextStyle(fontSize: 12)),
                                  ],
                                )),
                                DataCell(Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Direction: ${item.direction == 'in' ? 'Credit' : item.direction == 'out' ? 'Debit' : 'N/A'}',
                                      style:
                                      const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                        'Amount: ৳${item.amount.toStringAsFixed(2)}',
                                        style:
                                        const TextStyle(fontSize: 12)),
                                  ],
                                )),
                                DataCell(_getStatusChip(item.status)),
                                const DataCell(Text('N/A')),
                                DataCell(Text(item.note ?? 'N/A')),
                                DataCell(
                                  item.invoiceNo != 0
                                      ? (downloadingInvoices.contains(
                                      item.invoiceNo.toString())
                                      ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                    CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                      : IconButton(
                                    icon: const Icon(Icons.download,
                                        color: Colors.green),
                                    tooltip: 'Download Invoice',
                                    onPressed: () =>
                                        _downloadInvoiceToDownloads(
                                            context,
                                            item.invoiceNo
                                                .toString()),
                                  ))
                                      : const Text('N/A'),
                                ),
                              ]);
                            }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: currentPage > 1 ? _previousPage : null,
                    child: const Text('Previous'),
                  ),
                  const SizedBox(width: 16),
                  Text(
                      'Page $currentPage of ${(filteredHistory.length / rowsPerPage).ceil()}'),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: currentPage * rowsPerPage <
                        filteredHistory.length
                        ? _nextPage
                        : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
