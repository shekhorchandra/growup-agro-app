

//api
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
//
// class RechargePage extends StatefulWidget {
//   const RechargePage({super.key});
//
//   @override
//   State<RechargePage> createState() => _RechargePageState();
// }
//
// class _RechargePageState extends State<RechargePage> {
//   int _amount = 1000;
//   String _selectedMethod = 'bkash';
//   File? _selectedImage;
//   String _investorCode = '';
//   bool _isSubmitting = false;
//
//   final TextEditingController _transactionIdController = TextEditingController();
//   final TextEditingController _mobileNumberController = TextEditingController();
//   final TextEditingController _searchController = TextEditingController();
//
//   final List<String> _methods = ['bkash', 'nagad', 'surjo pay', 'rocket'];
//   List<dynamic> _fullDepositHistory = [];
//   List<dynamic> _filteredDepositHistory = [];
//
//   // Pagination
//   int _currentPage = 0;
//   final int _perPage = 5;
//
//   // Filter
//   String? _filterMethod;
//   DateTime? _startDate;
//   DateTime? _endDate;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInvestorCode();
//   }
//
//   Future<void> _loadInvestorCode() async {
//     final prefs = await SharedPreferences.getInstance();
//     final code = prefs.getString('auth_investor_code') ?? 'INVS-003241';
//     setState(() {
//       _investorCode = code;
//     });
//     _fetchDepositHistory();
//   }
//
//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _selectedImage = File(picked.path));
//     }
//   }
//
//   Future<void> _submitDeposit() async {
//     if (_transactionIdController.text.isEmpty || _mobileNumberController.text.isEmpty || _selectedImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields and select an image')));
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     final uri = Uri.parse('https://admin-growup.onebitstore.site/api/deposit-request');
//     final request = http.MultipartRequest('POST', uri);
//
//     request.fields['investor_code'] = _investorCode;
//     request.fields['amount'] = _amount.toString();
//     request.fields['method'] = _selectedMethod;
//     request.fields['transaction_id'] = _transactionIdController.text;
//     request.fields['mobile_number'] = _mobileNumberController.text;
//
//     request.files.add(await http.MultipartFile.fromPath('deposit_doc', _selectedImage!.path));
//
//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();
//
//     setState(() => _isSubmitting = false);
//
//     if (response.statusCode == 200) {
//       final data = json.decode(responseBody);
//       if (data['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
//         _transactionIdController.clear();
//         _mobileNumberController.clear();
//         setState(() {
//           _selectedImage = null;
//         });
//         _fetchDepositHistory();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission failed')));
//     }
//   }
//
//   Future<void> _fetchDepositHistory() async {
//     final url = Uri.parse('https://admin-growup.onebitstore.site/api/deposit-history?investor_code=$_investorCode');
//
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       final jsonData = jsonDecode(response.body);
//       if (jsonData['success'] == true) {
//         setState(() {
//           _fullDepositHistory = jsonData['data'];
//         });
//         _applyFilters();
//       }
//     }
//   }
//
//   void _applyFilters() {
//     setState(() {
//       _filteredDepositHistory = _fullDepositHistory.where((item) {
//         final methodMatch = _filterMethod == null || item['payment_method'] == _filterMethod;
//         final trxMatch = _searchController.text.isEmpty || (item['transaction_id']?.contains(_searchController.text) ?? false);
//
//         final submittedAt = DateTime.tryParse(item['submitted_at'] ?? '');
//         final dateMatch = (_startDate == null || (submittedAt != null && submittedAt.isAfter(_startDate!.subtract(const Duration(days: 1)))))
//             && (_endDate == null || (submittedAt != null && submittedAt.isBefore(_endDate!.add(const Duration(days: 1)))));
//
//         return methodMatch && trxMatch && dateMatch;
//       }).toList();
//     });
//   }
//
//   Future<void> _selectDateRange(BuildContext context) async {
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2023),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _startDate = picked.start;
//         _endDate = picked.end;
//       });
//       _applyFilters();
//     }
//   }
//
//   Widget _buildRechargeFormCard() {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             const Text("Deposit / Recharge", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Row(
//               children: [
//                 const Text("Amount:"),
//                 IconButton(onPressed: () => setState(() => _amount = (_amount - 100).clamp(0, 100000)), icon: const Icon(Icons.remove)),
//                 Text('৳$_amount', style: const TextStyle(fontSize: 16)),
//                 IconButton(onPressed: () => setState(() => _amount += 100), icon: const Icon(Icons.add)),
//               ],
//             ),
//             DropdownButtonFormField<String>(
//               value: _selectedMethod,
//               items: _methods.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
//               onChanged: (val) => setState(() => _selectedMethod = val!),
//               decoration: const InputDecoration(labelText: "Payment Method"),
//             ),
//             TextField(controller: _transactionIdController, decoration: const InputDecoration(labelText: "Transaction ID")),
//             TextField(controller: _mobileNumberController, decoration: const InputDecoration(labelText: "Mobile Number")),
//             const SizedBox(height: 10),
//             _selectedImage != null
//                 ? Image.file(_selectedImage!, height: 100)
//                 : const Text("No image selected"),
//             TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text("Pick Image")),
//             _isSubmitting
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(onPressed: _submitDeposit, child: const Text("Submit Deposit")),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHistoryFilter() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Wrap(
//         spacing: 12,
//         runSpacing: 8,
//         children: [
//           SizedBox(
//             width: 200,
//             child: TextField(
//               controller: _searchController,
//               decoration: const InputDecoration(labelText: 'Search by Transaction ID'),
//               onChanged: (val) => _applyFilters(),
//             ),
//           ),
//           DropdownButton<String>(
//             hint: const Text('Filter by Method'),
//             value: _filterMethod,
//             items: [null, ..._methods].map((method) {
//               return DropdownMenuItem<String>(
//                 value: method,
//                 child: Text(method == null ? 'All' : method.toUpperCase()),
//               );
//             }).toList(),
//             onChanged: (val) => setState(() {
//               _filterMethod = val;
//               _applyFilters();
//             }),
//           ),
//           TextButton.icon(
//             onPressed: () => _selectDateRange(context),
//             icon: const Icon(Icons.date_range),
//             label: Text(_startDate == null ? 'Filter by Date' : '${DateFormat.yMd().format(_startDate!)} - ${DateFormat.yMd().format(_endDate!)}'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDepositHistoryTable() {
//     final paginated = _filteredDepositHistory.skip(_currentPage * _perPage).take(_perPage).toList();
//
//     return Column(
//       children: [
//         _buildHistoryFilter(),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             headingRowColor: MaterialStateProperty.resolveWith((_) => Colors.grey[200]!),
//             columns: const [
//               DataColumn(label: Text("Date")),
//               DataColumn(label: Text("Amount")),
//               DataColumn(label: Text("Method")),
//               DataColumn(label: Text("Status")),
//               DataColumn(label: Text("Note")),
//               DataColumn(label: Text("Action")),
//             ],
//             rows: paginated.map<DataRow>((item) {
//               return DataRow(cells: [
//                 DataCell(Text(item['submitted_at'] ?? '')),
//                 DataCell(Text(item['amount'].toString())),
//                 DataCell(Text(item['payment_method'] ?? '')),
//                 DataCell(Text(item['status'].toUpperCase())),
//                 DataCell(Text(item['note'] ?? 'N/A')),
//                 DataCell(const Icon(Icons.visibility)),
//               ]);
//             }).toList(),
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.chevron_left),
//               onPressed: _currentPage > 0
//                   ? () => setState(() => _currentPage--)
//                   : null,
//             ),
//             Text('Page ${_currentPage + 1} of ${( (_filteredDepositHistory.length / _perPage).ceil() ).clamp(1, 999)}'),
//             IconButton(
//               icon: const Icon(Icons.chevron_right),
//               onPressed: (_currentPage + 1) * _perPage < _filteredDepositHistory.length
//                   ? () => setState(() => _currentPage++)
//                   : null,
//             ),
//           ],
//         )
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Recharge")),
//       body: ListView(
//         children: [
//           _buildRechargeFormCard(),
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text("Deposit History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ),
//           _buildDepositHistoryTable(),
//         ],
//       ),
//     );
//   }
// }








































/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:growup_agro/models/investment_history_model.dart';
import 'package:growup_agro/models/my_recharge_wallet_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  late Future<List<TransactionModel>> futureHistory;
  // String selectedEntries = '10';


  @override
  void initState() {
    super.initState();
    futureHistory = fetchTransactionModel();
  }

  Future<List<TransactionModel>> fetchTransactionModel() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final investorCode = prefs.getString('investor_code') ?? '';

    if (token.isEmpty || investorCode.isEmpty) {
      throw Exception("Missing token or investor code. Please log in again.");
    }

    final url = Uri.parse('https://admin-growup.onebitstore.site/api/wallet-history');

    print("Calling URL: $url");
    print("Token used: $token");

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List data = body['data'];
      return data.map((e) => TransactionModel.fromJson(e)).toList(); // ✅ fixed
    } else {
      throw Exception('Error ${response.statusCode}: ${json.decode(response.body)['message'] ?? 'Unknown error'}');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Green-tinted background
      appBar: AppBar(
        title: const Text("My Wallet", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No investment history found."));
          }

          final history = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 32,
                dataRowHeight: 100,
                headingRowHeight: 60,
                headingRowColor: MaterialStateProperty.all(const Color(0xFF388E3C)),
                headingTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                columns: const [
                  DataColumn(label: Text('Transaction Info')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actioned By')),
                  DataColumn(label: Text('Note')),
                  DataColumn(label: Text('Invoice')),
                ],
                rows: history.map((item) {
                  final createdAtFormatted = item.createdAt != null
                      ? "${item.createdAt!.toLocal()}".split('.')[0] // format DateTime
                      : 'N/A';

                  return DataRow(cells: [
                    /// Transaction Info
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trx ID: ${item.trxId}'),
                          Text('Type: ${item.type}'),
                          Text('Date: $createdAtFormatted', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),

                    /// Amount + Direction
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('৳${item.amount ?? '0.00'}'),
                          Text('Direction: ${item.direction}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),

                    /// Status
                    const DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Complete', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    /// Actioned By
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Credit A/C ID: ${item.creditAccountId}'),
                          Text('Debit A/C ID: ${item.debitAccountId}'),
                        ],
                      ),
                    ),

                    /// Note
                    DataCell(
                      Text(item.note ?? 'N/A'),
                    ),

                    /// Invoice Icons
                    DataCell(
                      Row(
                        children: [
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                tooltip: 'View Invoice',
                                onPressed: () {
                                  // TODO: View logic
                                },
                              ),
                              const Text('View', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download, color: Colors.green),
                                tooltip: 'Download Invoice',
                                onPressed: () {
                                  // TODO: Download logic
                                },
                              ),
                              const Text('Download', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
          ;
        },
      ),

    );
  }
}

 */
