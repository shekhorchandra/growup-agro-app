// import 'package:flutter/material.dart';
//
//
// class DepositPage extends StatefulWidget {
//   final int? projectId;
//
//   const DepositPage({Key? key, this.projectId}) : super(key: key);
//
//   @override
//   State<DepositPage> createState() => _DepositPageState();
// }
//
// class _DepositPageState extends State<DepositPage> {
//   List<DepositHistory> _depositHistory = [];
//
//   String _selectedMethod = 'Selected Method';
//   File? _selectedImage;
//   String _investorCode = '';
//   bool _isSubmitting = false;
//   bool _isLoading = false;
//
//   List<dynamic> _depositHistory = [];
//   List<dynamic> _filteredDepositHistory = [];
//   Set<String> downloadingInvoices = {};
//
//   int _currentPage = 0;
//   final int _itemsPerPage = 10;
//
//   final TextEditingController _amountController = TextEditingController(
//     text: '100',
//   );
//   final TextEditingController _transactionIdController =
//   TextEditingController();
//   final TextEditingController _mobileNumberController = TextEditingController();
//   final TextEditingController _bankNameController = TextEditingController();
//   final TextEditingController _shurjopayController = TextEditingController();
//   final TextEditingController _searchController = TextEditingController();
//
//   final List<String> _methods = [
//     'Selected Method',
//     'Bkash',
//     'Nagad',
//     'Rocket',
//     'Bank Transfer',
//     "Shurjo Pay",
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInvestorCode();
//     _searchController.addListener(_applyFilter);
//   }
//
//
//   Future<void> _loadInvestorCode() async {
//     final prefs = await SharedPreferences.getInstance();
//     final code = prefs.getString('investor_code') ?? '';
//     setState(() => _investorCode = code);
//     _fetchDepositHistory();
//   }
//
//   Future<void> _fetchDepositHistory() async {
//     setState(() => _isLoading = true);
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token') ?? '';
//     final uri = Uri.parse(
//       'https://admin-growup.onebitstore.site/api/investor/deposit-history?investor_code=$_investorCode',
//     );
//
//     try {
//       final response = await http.get(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         if (decoded['success']) {
//           List<dynamic> data = decoded['data'];
//           data.sort(
//                 (a, b) => DateTime.parse(
//               b['updated_at'],
//             ).compareTo(DateTime.parse(a['updated_at'])),
//           );
//           setState(() {
//             _depositHistory = data;
//             _filteredDepositHistory = List.from(_depositHistory);
//             _currentPage = 0;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching deposit history: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _applyFilter() {
//     final query = _searchController.text.toLowerCase().trim();
//     setState(() {
//       _filteredDepositHistory = query.isEmpty
//           ? List.from(_depositHistory)
//           : _depositHistory.where((d) {
//         return (d['amount'].toString().toLowerCase().contains(query)) ||
//             (d['payment_method'].toString().toLowerCase().contains(
//               query,
//             )) ||
//             (d['status'].toString().toLowerCase().contains(query));
//       }).toList();
//       _currentPage = 0;
//     });
//   }
//
//   List<dynamic> get _paginatedDepositHistory {
//     final start = _currentPage * _itemsPerPage;
//     final end = (start + _itemsPerPage).clamp(
//       0,
//       _filteredDepositHistory.length,
//     );
//     return _filteredDepositHistory.sublist(start, end);
//   }
//
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Colors.orange;
//       case 'approved':
//         return Colors.green;
//       case 'rejected':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//
//
//   Widget _buildDepositForm() {
//     final method = _selectedMethod.toLowerCase();
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: _amountController,
//             decoration: const InputDecoration(
//               labelText: 'Amount',
//               border: OutlineInputBorder(),
//             ),
//             keyboardType: TextInputType.number,
//           ),
//           const SizedBox(height: 12),
//           DropdownButtonFormField<String>(
//             value: _selectedMethod,
//             decoration: const InputDecoration(
//               labelText: 'Deposit Method',
//               border: OutlineInputBorder(),
//             ),
//             items: _methods
//                 .map((m) => DropdownMenuItem(value: m, child: Text(m)))
//                 .toList(),
//             onChanged: (val) => setState(() => _selectedMethod = val!),
//           ),
//           const SizedBox(height: 12),
//           if (['bkash', 'nagad', 'rocket'].contains(method)) ...[
//             TextField(
//               controller: _transactionIdController,
//               decoration: const InputDecoration(
//                 labelText: 'Transaction ID',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _mobileNumberController,
//               decoration: const InputDecoration(
//                 labelText: 'Mobile Number',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//           if (method == 'bank transfer') ...[
//             TextField(
//               controller: _bankNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Bank Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             _selectedImage != null
//                 ? Image.file(_selectedImage!, height: 100)
//                 : Center(child: const Text("Upload Document (Pdf or Image)")),
//             Center(
//               child: TextButton.icon(
//                 onPressed: _pickImage,
//                 icon: const Icon(Icons.add_a_photo, size: 40),
//                 label: const Text(""),
//               ),
//             ),
//           ],
//           if (method == 'Shurjo Pay') ...[
//             TextField(
//               controller: _shurjopayController,
//               decoration: const InputDecoration(
//                 labelText: 'Shurjo Pay',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//           const SizedBox(height: 10),
//           _isSubmitting || (_selectedMethod == 'Shurjo Pay' && _isLoading)
//               ? const Center(child: CircularProgressIndicator())
//               : SizedBox(
//             width: double.infinity,
//             child: _selectedMethod == 'Shurjo Pay'
//                 ? ElevatedButton(
//               onPressed: _handleShurjoPay,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2E7D32),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: const Text(
//                 'Pay with ShurjoPay',
//                 style: TextStyle(color: Colors.white),
//               ),
//             )
//                 : ElevatedButton(
//               onPressed: _submitDeposit,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2E7D32),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: const Text(
//                 'Submit Deposit',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//           TextField(
//             controller: _searchController,
//
//             decoration: InputDecoration(
//               labelText: 'Search by amount, status and method Deposit History',
//               prefixIcon: const Icon(Icons.search),
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: Colors.grey),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildDepositHistoryTable(),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _currentPage > 0
//                     ? () => setState(() => _currentPage--)
//                     : null,
//                 child: const Text('Previous'),
//               ),
//               const SizedBox(width: 20),
//               Text(
//                 'Page ${_currentPage + 1} of ${(_filteredDepositHistory.length / _itemsPerPage).ceil()}',
//               ),
//               const SizedBox(width: 20),
//               ElevatedButton(
//                 onPressed:
//                 (_currentPage + 1) * _itemsPerPage <
//                     _filteredDepositHistory.length
//                     ? () => setState(() => _currentPage++)
//                     : null,
//                 child: const Text('Next'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDepositHistoryTable() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());
//     if (_filteredDepositHistory.isEmpty)
//       return const Center(child: Text('No deposit history found.'));
//
//     final currentItems = _paginatedDepositHistory;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Center(
//           child: const Text(
//             'Deposit History',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ),
//         const SizedBox(height: 12),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Card(
//             // margin: const EdgeInsets.all(8), // smaller outer margin
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             elevation: 2,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal, // in case table is wide
//               child: DataTable(
//                 headingRowColor: MaterialStateProperty.all(
//                   const Color(0xFF388E3C),
//                 ),
//                 headingTextStyle: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 dataRowMinHeight: 48,
//                 dataRowMaxHeight: 56, // tighter row spacing
//                 columnSpacing: 12, // reduce spacing between columns
//                 columns: const [
//                   DataColumn(label: Text('SL')),
//                   DataColumn(label: Text('Date')),
//                   DataColumn(label: Text('Amount')),
//                   DataColumn(label: Text('Method')),
//                   DataColumn(label: Text('Status')),
//
//                 ],
//                 rows: List.generate(currentItems.length, (index) {
//                   final item = currentItems[index];
//                   final invoiceNo = item['invoice_no'];
//                   final hasInvoice = invoiceNo != null && invoiceNo != 0;
//                   return DataRow(
//                     cells: [
//                       DataCell(
//                         Text('${_currentPage * _itemsPerPage + index + 1}'),
//                       ),
//                       DataCell(
//                         Text(_formatDate(item['updated_at'].toString())),
//                       ),
//                       DataCell(Text(item['amount'].toString())),
//                       DataCell(Text(item['payment_method'].toString())),
//                       DataCell(
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _getStatusColor(item['status'].toString()),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//
//                         ),
//                       ),
//
//
//                     ],
//                   );
//                 }),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // centerTitle: true,
//         // backgroundColor: const Color(0xFF2E7D32),
//         // foregroundColor: Colors.white,
//         title: const Text(
//           "Deposit History",
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: _buildDepositForm(),
//           ),
//         ),
//       ),
//     );
//   }
//
//
// }