import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ProjectInvestmentDetailPage extends StatefulWidget {
  final int projectId;
  final String projectTitle;
  final String projectCategory;

  const ProjectInvestmentDetailPage({
    super.key,
    required this.projectId,
    required this.projectTitle,
    required this.projectCategory,
  });

  @override
  State<ProjectInvestmentDetailPage> createState() =>
      _ProjectInvestmentDetailPageState();
}

class _ProjectInvestmentDetailPageState extends State<ProjectInvestmentDetailPage> {
  List<dynamic> allInvestments = [];
  List<dynamic> filteredInvestments = [];
  Set<String> downloadingInvoices = {};


  final TextEditingController _searchController = TextEditingController();

  int currentPage = 1;
  final int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchInvestments();
    _searchController.addListener(() {
      _filterInvestments(_searchController.text);
    });
  }

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy, h:mm a').format(date); // Customize as needed
    } catch (e) {
      return rawDate;
    }
  }


  void _filterInvestments(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredInvestments = allInvestments.where((item) {
        final invoice = item['invoice_no']?.toString() ?? '';
        final amount = item['amount']?.toString() ?? '';
        return invoice.contains(lowerQuery) || amount.contains(lowerQuery);
      }).toList();
      currentPage = 1; // Reset to first page on search
    });
  }

  List<dynamic> get currentPageItems {
    final startIndex = (currentPage - 1) * rowsPerPage;
    final endIndex = (startIndex + rowsPerPage) > filteredInvestments.length
        ? filteredInvestments.length
        : startIndex + rowsPerPage;
    return filteredInvestments.sublist(startIndex, endIndex);
  }

  Future<void> _fetchInvestments() async {
    final prefs = await SharedPreferences.getInstance();
    final investorCode = prefs.getString('investor_code') ?? '';
    final token = prefs.getString('auth_token') ?? '';

    // final url = Uri.parse(
    //     'https://admin-growup.onebitstore.site/api/peoject/investment/detail?investor_code=$investorCode&project_id=${widget
    //         .projectId}');

    final url = Uri.parse(
      ApiConstants.projectInvestmentDetail(
        investorCode,
        widget.projectId.toString(),
      ),
    );


    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];
        setState(() {
          allInvestments = data;
          filteredInvestments = data;
        });
      } else {
        throw Exception('Failed to load project investments');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
    }
  }

  void _nextPage() {
    final totalPages = (filteredInvestments.length / rowsPerPage).ceil();
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (filteredInvestments.length / rowsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text('Investments Details', style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by amount or invoice',
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
                Expanded(
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: constraints.maxWidth),
                        child: SingleChildScrollView(
                          child: Card(
                            child: DataTable(
                              columnSpacing: 24,
                              dataRowHeight: 72,
                              // ✅ This is valid and avoids conflict
                              headingRowColor: MaterialStateProperty.all(
                                  Colors.green.shade700),
                              headingTextStyle: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                              columns: const [
                                DataColumn(label: Text('SL')),
                                DataColumn(label: Text('Project')),
                                DataColumn(label: Text('Investment')),
                                DataColumn(label: Text('Invoice No')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: List.generate(currentPageItems.length, (index) {
                                final item = currentPageItems[index];
                                final serial = ((currentPage - 1) * rowsPerPage) +
                                    index + 1;
                                                
                                return DataRow(
                                  cells: [
                                    DataCell(Text('$serial')),
                                                
                                    // Project (Title, Category, ID)
                                    DataCell(Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(widget.projectTitle,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text('Category: ${widget.projectCategory}',
                                            style: const TextStyle(fontSize: 12)),
                                                
                                        Text('Project ID: ${widget.projectId}',
                                            style: const TextStyle(fontSize: 12)),
                                      ],
                                    )),
                                                
                                    // Investment (Amount, Updated Date)
                                    DataCell(Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('৳${item['amount']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(formatDate(item['updated_at']),
                                            style: const TextStyle(fontSize: 12, color: Colors.grey)),

                                      ],
                                    )),
                                                
                                    // Invoice No
                                    DataCell(
                                        Text(item['invoice_no'].toString())),
                                                
                                    // Actions (View, Download)
                                    DataCell(
                                      item['invoice_no'] != null &&
                                          item['invoice_no'] != 0
                                          ? (downloadingInvoices.contains(
                                          item['invoice_no'].toString())
                                          ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                          : IconButton(
                                        icon: const Icon(
                                            Icons.download, color: Colors.green),
                                        tooltip: 'Download Invoice',
                                        onPressed: () {
                                          _downloadInvoice(context,
                                              item['invoice_no'].toString());
                                        },
                                      ))
                                          : const Text('N/A'),
                                    ),
                                                
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Pagination Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: currentPage > 1 ? _previousPage : null,
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 16),
                      Text('Page $currentPage of $totalPages'),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: currentPage < totalPages ? _nextPage : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  Future<void> _downloadInvoice(BuildContext context, String invoiceNo) async {
    setState(() {
      downloadingInvoices.add(invoiceNo);
    });

    final dio = Dio();
    final url = ApiConstants.invoicePdf(invoiceNo);

    try {
      // ✅ Get app-specific directory (sandboxed, no storage permission needed)
      Directory downloadsDir;
      if (Platform.isAndroid || Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = Directory.systemTemp;
      }

      final filePath = '${downloadsDir.path}/invoice_$invoiceNo.pdf';

      // ✅ Download invoice
      await dio.download(url, filePath);

      // ✅ Open the downloaded PDF
      await OpenFile.open(filePath);

      // ✅ Show success snackbar with share option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice downloaded and opened successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
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
}





