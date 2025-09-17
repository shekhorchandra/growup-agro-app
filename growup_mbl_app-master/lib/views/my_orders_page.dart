import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_order_model.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  late Future<List<Order>> _ordersFuture;

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  int _currentPage = 1;
  final int _rowsPerPage = 10;

  final TextEditingController _searchController = TextEditingController();
  final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '৳');

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();

    _searchController.addListener(() {
      _searchOrders(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Order>> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final investorCode = prefs.getString('investor_code') ?? '';

    final response = await http.get(
      Uri.parse("https://admin-growup.onebitstore.site/api/my-orders?investor_code=$investorCode"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final orderResponse = OrderResponse.fromJson(jsonData);
      _allOrders = orderResponse.data;
      _filteredOrders = _allOrders;
      return _filteredOrders;
    } else {
      throw Exception("Failed to fetch orders");
    }
  }

  void _searchOrders(String query) {
    setState(() {
      _filteredOrders = _allOrders.where((order) {
        return order.productName.toLowerCase().contains(query.toLowerCase()) ||
            order.invoiceNo.toString().contains(query) ||
            order.status.toLowerCase().contains(query.toLowerCase());
      }).toList();
      _currentPage = 1;
    });
  }

  List<Order> get currentPageOrders {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > _filteredOrders.length
        ? _filteredOrders.length
        : (startIndex + _rowsPerPage);
    return _filteredOrders.sublist(startIndex, endIndex);
  }

  void _nextPage() {
    if (_currentPage * _rowsPerPage < _filteredOrders.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders",style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        centerTitle: true, // <-- This centers the title on all phones
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,// or your preferred color
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          if (_allOrders.isEmpty) {
            _allOrders = snapshot.data!;
            _filteredOrders = _allOrders;
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by Product, Invoice, Status',
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

              // Table
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Card(
                      child: DataTable(
                        columnSpacing: 24,
                        dataRowHeight: 70,
                        headingRowHeight: 60,
                        headingRowColor:
                        MaterialStateProperty.all(const Color(0xFF388E3C)),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        columns: const [
                          DataColumn(label: Text("SL")),
                          DataColumn(label: Text("Order")),
                          DataColumn(label: Text("Product")),
                          DataColumn(label: Text("Payable")),
                          DataColumn(label: Text("Paid")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: currentPageOrders.asMap().entries.map((entry) {
                          final index = entry.key;
                          final order = entry.value;
                          final slNumber =
                              ((_currentPage - 1) * _rowsPerPage) + index + 1;

                          return DataRow(cells: [
                            DataCell(Text('$slNumber')),
                            DataCell(Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Invoice: ${order.invoiceNo}"),
                                Text(order.orderDate,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            )),
                            DataCell(Text(order.productName)),
                            DataCell(Text(currencyFormatter.format(order.totalPayable))),
                            DataCell(Text(currencyFormatter.format(order.paidAmount))),
                            DataCell(Text(
                              order.status,
                              style: TextStyle(
                                  color: order.status == "Confirmed"
                                      ? Colors.green
                                      : Colors.red),
                            )),
                            const DataCell(Icon(Icons.more_horiz)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),

              // Pagination footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage > 1 ? _previousPage : null,
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Page $_currentPage of ${(_filteredOrders.length / _rowsPerPage).ceil()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _currentPage * _rowsPerPage < _filteredOrders.length
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
