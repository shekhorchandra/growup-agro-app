import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growup_agro/models/roi_model.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RoiDetailsPage extends StatefulWidget {
  final String investorCode;
  final int projectId;

  const RoiDetailsPage({
    super.key,
    required this.investorCode,
    required this.projectId,
  });

  @override
  State<RoiDetailsPage> createState() => _RoiDetailsPageState();
}

class _RoiDetailsPageState extends State<RoiDetailsPage> {
  List<RoiModel> allData = [];
  List<RoiModel> filteredData = [];

  int rowsPerPage = 10;
  int currentPage = 0;

  final TextEditingController _searchController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRoiData();
  }

  String formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy').format(date); // Example: 16 Jul 2025
    } catch (e) {
      return rawDate;
    }
  }


  Future<void> fetchRoiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token missing. Please log in again.")),
      );
      return;
    }

    // final url = Uri.https(
    //   'admin-growup.onebitstore.site',
    //   '/api/roi-list',
    //   {
    //     'investor_code': widget.investorCode,
    //     'project_id': widget.projectId.toString(),
    //   },
    // );

    final url = Uri.parse(
      ApiConstants.roiList(widget.investorCode, widget.projectId.toString()),
    );

    print('Fetching ROI Data from: $url');
    print('Using token: $token');
    print('Using investorCode: ${widget.investorCode}');
    print('Using projectId: ${widget.projectId}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List data = jsonData['data'];
          setState(() {
            allData = data.map((e) => RoiModel.fromJson(e)).toList();
            filteredData = allData;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No ROI data found.")),
          );
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ${response.statusCode}: Failed to load data")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    }
  }


  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredData = allData;
      } else {
        filteredData = allData.where((roi) {
          final formattedDate = formatDate(roi.countingDate).toLowerCase(); // e.g. '05 May 2025'
          final amount = roi.roiAmount.toString();
          return formattedDate.contains(query.toLowerCase()) ||
              amount.contains(query);
        }).toList();
      }
      currentPage = 0;
    });
  }



  @override
  Widget build(BuildContext context) {
    final int totalPages =
    (filteredData.length / rowsPerPage).ceil();

    final currentItems = filteredData.skip(currentPage * rowsPerPage).take(rowsPerPage).toList();

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          title: const Text('ROI Details',style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,)
          )),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by date (e.g. 05 May) or amount',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: _filterSearch,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                child: SingleChildScrollView(
                  child: Card(
                    child: DataTable(
                      columnSpacing: 24,
                      dataRowHeight: 72,
                      headingRowColor: MaterialStateProperty.all(const Color(0xFF388E3C)),
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      columns: const [
                        DataColumn(label: Text('SL')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Amount')),
                      ],
                      rows: List.generate(currentItems.length, (index) {
                        final roi = currentItems[index];
                        return DataRow(cells: [
                          DataCell(Text('${(currentPage * rowsPerPage) + index + 1}')),
                          DataCell(Text(formatDate(roi.countingDate))),
                          DataCell(Text('${NumberFormat("#,##0.00").format(roi.roiAmount)} BDT')),
                        ]);
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: currentPage > 0
                    ? () => setState(() => currentPage--)
                    : null,
                child: const Text('Previous'),
              ),
              const SizedBox(width: 16),
              Text('Page ${currentPage + 1} of $totalPages'),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: currentPage < totalPages - 1
                    ? () => setState(() => currentPage++)
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
