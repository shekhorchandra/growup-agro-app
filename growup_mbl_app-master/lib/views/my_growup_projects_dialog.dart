import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/my_growup_projects_dialog_model.dart';

class MyGrowupProjectsDialog extends StatefulWidget {
  const MyGrowupProjectsDialog({super.key});

  @override
  State<MyGrowupProjectsDialog> createState() => _MyGrowupProjectsDialogState();
}

class _MyGrowupProjectsDialogState extends State<MyGrowupProjectsDialog> {
  bool isLoading = false;
  List<Project> projects = [];
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  int currentPage = 1;
  final int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final investorCode = prefs.getString('investor_code') ?? '';

      final response = await http.get(
        Uri.parse(
            'https://admin-growup.onebitstore.site/api/investor/pop-up/my-projects?investor_code=$investorCode'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<Project> loaded = (jsonData['data']['projects'] as List)
            .map((e) => Project.fromJson(e))
            .toList();
        setState(() => projects = loaded);
      } else {
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Project> get filteredProjects {
    if (searchQuery.isEmpty) return projects;
    return projects
        .where((p) =>
        p.projectName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<Project> get currentPageItems {
    final filtered = filteredProjects;
    final start = (currentPage - 1) * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  void _nextPage() {
    if (currentPage * rowsPerPage < filteredProjects.length) {
      setState(() => currentPage++);
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
    }
  }
  void _filterList(String value) {
    setState(() {
      searchQuery = value;
      currentPage = 1;
    });
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'My GrowUp Projects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by project name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _filterList,
            ),
            // child: TextField(
            //   controller: _searchController,
            //   decoration: InputDecoration(
            //     labelText: 'Search by project name...',
            //     prefixIcon: const Icon(Icons.search),
            //     suffixIcon: searchQuery.isNotEmpty
            //         ? IconButton(
            //       icon: const Icon(Icons.clear),
            //       onPressed: () {
            //         _searchController.clear();
            //         setState(() {
            //           searchQuery = '';
            //           currentPage = 1;
            //         });
            //       },
            //     )
            //         : null,
            //     border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10)),
            //   ),
            //   onChanged: (value) {
            //     setState(() {
            //       searchQuery = value;
            //       currentPage = 1;
            //     });
            //   },
            // ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Card(
                  child: DataTable(
                    columnSpacing: 32,
                    headingRowColor:
                    MaterialStateProperty.all(const Color(0xFF388E3C)),
                    headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    columns: const [
                      DataColumn(label: Text('SL')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Investment')),
                    ],
                    rows: List.generate(currentPageItems.length, (index) {
                      final item = currentPageItems[index];
                      return DataRow(cells: [
                        DataCell(Text(
                            '${(currentPage - 1) * rowsPerPage + index + 1}')),
                        DataCell(Text(item.projectName)),
                        DataCell(Text('৳${item.totalInvestment}')),
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
              ElevatedButton(
                  onPressed: _previousPage,
                  child: const Text('Previous')),
              const SizedBox(width: 16),
              Text(
                  'Page $currentPage of ${(filteredProjects.length / rowsPerPage).ceil()}'),
              const SizedBox(width: 16),
              ElevatedButton(
                  onPressed: _nextPage, child: const Text('Next')),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Close",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
