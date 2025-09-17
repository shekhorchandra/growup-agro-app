import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class DepositPage extends StatefulWidget {
  final int? projectId;

  const DepositPage({Key? key, this.projectId}) : super(key: key);

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  String _selectedMethod = 'Selected Method';
  File? _selectedImage;
  String _investorCode = '';
  bool _isSubmitting = false;
  bool _isLoading = false;

  List<dynamic> _depositHistory = [];
  List<dynamic> _filteredDepositHistory = [];
  Set<String> downloadingInvoices = {};

  int _currentPage = 0;
  final int _itemsPerPage = 10;

  final TextEditingController _amountController = TextEditingController(
    text: '100',
  );
  final TextEditingController _transactionIdController =
      TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _shurjopayController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _methods = [
    'Selected Method',
    'Bkash',
    'Nagad',
    'Rocket',
    'Bank Transfer',
    "Shurjo Pay",
  ];

  @override
  void initState() {
    super.initState();
    _loadInvestorCode();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy, h:mm a').format(date); // Example: 16 Jul 2025
    } catch (e) {
      return rawDate;
    }
  }


  Future<void> _handleRefresh() async {
    await _loadInvestorCode();
  }

  Future<void> _loadInvestorCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('investor_code') ?? '';
    setState(() => _investorCode = code);
    _fetchDepositHistory();
  }

  Future<void> _fetchDepositHistory() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    // final uri = Uri.parse(
    //   'https://admin-growup.onebitstore.site/api/investor/deposit-history?investor_code=$_investorCode',
    // );
    final url = ApiConstants.depositHistory(_investorCode);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success']) {
          List<dynamic> data = decoded['data'];
          data.sort(
            (a, b) => DateTime.parse(
              b['updated_at'],
            ).compareTo(DateTime.parse(a['updated_at'])),
          );
          setState(() {
            _depositHistory = data;
            _filteredDepositHistory = List.from(_depositHistory);
            _currentPage = 0;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching deposit history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredDepositHistory = query.isEmpty
          ? List.from(_depositHistory)
          : _depositHistory.where((d) {
              return (d['amount'].toString().toLowerCase().contains(query)) ||
                  (d['payment_method'].toString().toLowerCase().contains(
                    query,
                  )) ||
                  (d['status'].toString().toLowerCase().contains(query));
            }).toList();
      _currentPage = 0;
    });
  }

  List<dynamic> get _paginatedDepositHistory {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(
      0,
      _filteredDepositHistory.length,
    );
    return _filteredDepositHistory.sublist(start, end);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _handleShurjoPay() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final investorCode = prefs.getString('investor_code') ?? '';
    final token = prefs.getString('auth_token');
    final investorId = prefs.getString('investor_id') ?? '';
    final email = prefs.getString('investor_email') ?? 'default@email.com';

    if (investorCode.isEmpty) {
      _showSnack("Investor code missing.");
      setState(() => _isLoading = false);
      return;
    }

    final enteredAmount = _amountController.text.trim();
    if (enteredAmount.isEmpty || double.tryParse(enteredAmount) == null) {
      _showSnack("Please enter a valid deposit amount.");
      setState(() => _isLoading = false);
      return;
    }

    final amount = double.parse(enteredAmount);

    try {
      // Step 1: Get ShurjoPay token
      final tokenResponse = await http.post(
        Uri.parse('https://sandbox.shurjopayment.com/api/get_token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': 'sp_sandbox',
          'password': 'pyyk97hu&6u6',
        }),
      );

      if (tokenResponse.statusCode != 200) {
        _showSnack("Failed to get payment token.");
        print('Token error body: ${tokenResponse.body}');
        setState(() => _isLoading = false);
        return;
      }

      final tokenData = jsonDecode(tokenResponse.body);
      final spToken = tokenData['token'];
      final storeId = tokenData['store_id'].toString();
      final orderId = 'growup_${DateTime.now().millisecondsSinceEpoch}';

      // Step 2: Initiate Payment
      final paymentResponse = await http.post(
        Uri.parse('https://sandbox.shurjopayment.com/api/secret-pay'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $spToken',
        },
        body: jsonEncode({
          "prefix": "sp",
          "token": spToken,
          "return_url":
              "https://admin-growup.onebitstore.site/api/shurjopay/payment/callback",
          "cancel_url":
              "https://admin-growup.onebitstore.site/api/shurjopay/cancel?status=fail",
          "store_id": storeId,
          "amount": amount,
          "order_id": orderId,
          "currency": "BDT",
          "customer_name": "GrowUp Investor",
          "customer_address": "Dhaka, Bangladesh",
          "customer_city": "Dhaka",
          "customer_email": email,
          "customer_phone": "+8801700000000",
          "customer_post_code": "1200",
          "client_ip": "127.0.0.1",
          "value1": investorId,
          "value2": widget.projectId?.toString() ?? '',
          "value3": "wallet_deposit",
          "value4": "",
        }),
      );

      print('Payment response status: ${paymentResponse.statusCode}');
      print('Payment response body: ${paymentResponse.body}');

      if (paymentResponse.statusCode != 200) {
        final errorJson = jsonDecode(paymentResponse.body);
        final errorMsg = errorJson['message'] ?? 'Payment initiation failed';
        _showSnack(errorMsg);
        setState(() => _isLoading = false);
        return;
      }

      final paymentData = jsonDecode(paymentResponse.body);
      final checkoutUrl =
          paymentData['checkout_url'] ?? paymentData['redirect_url'] ?? '';
      print('Checkout URL: $checkoutUrl');

      if (checkoutUrl.isNotEmpty && checkoutUrl.startsWith('http')) {
        final uri = Uri.parse(checkoutUrl);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          _showSnack("Could not open payment page.");
        }
      } else {
        _showSnack("Invalid payment URL.");
      }
    } catch (e) {
      _showSnack("Error during payment: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitDeposit() async {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    final method = _selectedMethod.toLowerCase();

    if (_selectedMethod == 'Selected Method') {
      _showSnack("Please select a deposit method.");
      return;
    }

    if (amount < 100) {
      _showSnack("Minimum deposit amount is 100.");
      return;
    }

    if (_investorCode.isEmpty) {
      _showSnack("Investor code missing.");
      return;
    }

    if (method == 'bank transfer') {
      if (_bankNameController.text.isEmpty || _selectedImage == null) {
        _showSnack("Please provide bank name and slip image.");
        return;
      }
    }

    if (['bkash', 'nagad', 'rocket'].contains(method)) {
      final mobileNumber = _mobileNumberController.text.trim();
      final transactionId = _transactionIdController.text.trim();

      if (transactionId.isEmpty || mobileNumber.isEmpty) {
        _showSnack("Transaction ID and Mobile number are required.");
        return;
      }

      final mobileRegex = RegExp(r'^01[3-9]\d{8}$'); // Valid BD mobile format
      if (!mobileRegex.hasMatch(mobileNumber)) {
        _showSnack("Please enter a valid Bangladeshi mobile number.");
        return;
      }
    }


    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    // final uri = Uri.parse(
    //   'https://admin-growup.onebitstore.site/api/deposit-request',
    // );
    final uri = Uri.parse(ApiConstants.depositRequest());
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['investor_code'] = _investorCode
      ..fields['amount'] = amount.toString()
      ..fields['payment_method'] = _selectedMethod == 'Bank Transfer'
          ? 'bank'
          : method;

    if (method == 'bank transfer') {
      request.fields['bank_name'] = _bankNameController.text;
      request.files.add(
        await http.MultipartFile.fromPath(
          'bank_payment_slip',
          _selectedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      request.fields['mobile_transaction_id'] = _transactionIdController.text;
      request.fields['mobile_number'] = _mobileNumberController.text;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonMap = json.decode(responseBody);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonMap['success']) {
        final newData = jsonMap['data'];
        newData['updated_at'] ??= DateTime.now().toIso8601String();
        setState(() {
          _transactionIdController.clear();
          _mobileNumberController.clear();
          _bankNameController.clear();
          _amountController.text = '100';
          _selectedImage = null;
          _depositHistory.insert(0, newData);
          _filteredDepositHistory = List.from(_depositHistory);
          _currentPage = 0;
        });
        _showSnack("Deposit request submitted successfully", isError: false);
      } else {
        _showSnack(jsonMap['message'] ?? 'Deposit submission failed.');
      }
    } catch (e) {
      debugPrint("Exception during deposit submission: $e");
      _showSnack("Something went wrong. Please try again.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDepositForm() {
    final method = _selectedMethod.toLowerCase();
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedMethod,
            decoration: const InputDecoration(
              labelText: 'Deposit Method',
              border: OutlineInputBorder(),
            ),
            items: _methods
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (val) => setState(() => _selectedMethod = val!),
          ),
          const SizedBox(height: 12),
          if (['bkash', 'nagad', 'rocket'].contains(method)) ...[
            TextField(
              controller: _transactionIdController,
              decoration: const InputDecoration(
                labelText: 'Transaction ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _mobileNumberController,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          if (method == 'bank transfer') ...[
            TextField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 100)
                : Center(child: const Text("Upload Document (Pdf or Image)")),
            Center(
              child: TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_a_photo, size: 40),
                label: const Text(""),
              ),
            ),
          ],
          if (method == 'Shurjo Pay') ...[
            TextField(
              controller: _shurjopayController,
              decoration: const InputDecoration(
                labelText: 'Shurjo Pay',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          _isSubmitting || (_selectedMethod == 'Shurjo Pay' && _isLoading)
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  child: _selectedMethod == 'Shurjo Pay'
                      ? ElevatedButton(
                          onPressed: _handleShurjoPay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Pay with ShurjoPay',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitDeposit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Submit Deposit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),

          const SizedBox(height: 20),
          TextField(
            controller: _searchController,

            decoration: InputDecoration(
              labelText: 'Search by amount, status and method Deposit History',
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
          const SizedBox(height: 16),
          _buildDepositHistoryTable(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                child: const Text('Previous'),
              ),
              const SizedBox(width: 20),
              Text(
                'Page ${_currentPage + 1} of ${(_filteredDepositHistory.length / _itemsPerPage).ceil()}',
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed:
                    (_currentPage + 1) * _itemsPerPage <
                        _filteredDepositHistory.length
                    ? () => setState(() => _currentPage++)
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepositHistoryTable() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_filteredDepositHistory.isEmpty)
      return const Center(child: Text('No deposit history found.'));

    final currentItems = _paginatedDepositHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: const Text(
            'Deposit History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Card(
            // margin: const EdgeInsets.all(8), // smaller outer margin
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // in case table is wide
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color(0xFF388E3C),
                ),
                headingTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56, // tighter row spacing
                columnSpacing: 12, // reduce spacing between columns
                columns: const [
                  DataColumn(label: Text('SL')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Method')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Note')),
                  DataColumn(label: Text('Action')),
                ],
                rows: List.generate(currentItems.length, (index) {
                  final item = currentItems[index];
                  final invoiceNo = item['invoice_no'];
                  final hasInvoice = invoiceNo != null && invoiceNo != 0;
                  return DataRow(
                    cells: [
                      DataCell(
                        Text('${_currentPage * _itemsPerPage + index + 1}'),
                      ),
                      DataCell(
                        Text(_formatDate(item['updated_at'].toString())),
                      ),
                      DataCell(Text(item['amount'].toString())),
                      DataCell(Text(item['payment_method'].toString())),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item['status'].toString()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['status'].toString().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(item['note']?.toString() ?? 'N/A')),
                      DataCell(
                        hasInvoice
                            ? (downloadingInvoices.contains(
                                    invoiceNo.toString(),
                                  )
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.download,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      tooltip: 'Download Invoice',
                                      onPressed: () =>
                                          _downloadInvoiceToDownloads(
                                            context,
                                            invoiceNo.toString(),
                                          ),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        // backgroundColor: const Color(0xFF2E7D32),
        // foregroundColor: Colors.white,
        title: const Text(
          "Deposit Funds",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: _buildDepositForm(),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadInvoiceToDownloads(
      BuildContext context,
      String invoiceNo,
      ) async {
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

      // ✅ Get app documents directory (no storage permission needed)
      Directory downloadsDir = await getApplicationDocumentsDirectory();

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
}
