import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/completed_projects_model.dart';

class CompletedProjectsPage extends StatefulWidget {
  final bool hideAppBar;
  const CompletedProjectsPage({super.key, this.hideAppBar = false});

  @override
  State<CompletedProjectsPage> createState() => _CompletedProjectsPageState();
}

class _CompletedProjectsPageState extends State<CompletedProjectsPage> {
  late Future<List<CompletedProject>> futureCompletedProjects;
  List<CompletedProject> _allProjects = [];
  List<CompletedProject> _filteredProjects = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    futureCompletedProjects = fetchCompletedProjects();
    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if (_scrollController.offset >= 300 && !_showBackToTopButton) {
        setState(() => _showBackToTopButton = true);
      } else if (_scrollController.offset < 300 && _showBackToTopButton) {
        setState(() => _showBackToTopButton = false);
      }
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProjects = _allProjects
          .where((project) => project.projectName.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<List<CompletedProject>> fetchCompletedProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final investorCode = prefs.getString('investor_code') ?? '';

    // final response = await http.get(
    //   Uri.parse('https://admin-growup.onebitstore.site/api/completed-projects?investor_code=$investorCode'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    // );
    final url = Uri.parse(ApiConstants.completedProjects(investorCode));
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        final List<dynamic> projectsJson = jsonData['projects'];
        _allProjects = projectsJson.map((json) => CompletedProject.fromJson(json)).toList();
        _filteredProjects = _allProjects;
        return _allProjects;
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      throw Exception('Failed to load Matured projects');
    }
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(value),
        ),
      ],
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideAppBar
          ? null
          : AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          'Matured Projects',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<CompletedProject>>(
        future: futureCompletedProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by project name...',
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
                child: _filteredProjects.isEmpty
                    ? const Center(child: Text('No matching projects found.'))
                    : ListView.builder(
                  controller: _scrollController,
                  itemCount: _filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = _filteredProjects[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (project.imageUrl != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                child: Image.network(
                                  project.imageUrl!,
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/placeholder1.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                project.projectName,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Table(
                                  columnWidths: const {
                                    0: FixedColumnWidth(140),
                                    1: FixedColumnWidth(220),
                                  },
                                  children: [
                                    _buildTableRow('Business Type:', project.projectName ?? 'N/A'),
                                    _buildTableRow('Investment Time:', '${project.remainingOpportunityDays ?? 'N/A'} days'),
                                    _buildTableRow('Investment Goal:', project.investmentGoal ?? 'N/A'),
                                    _buildTableRow('Raised:', project.raised?.toString() ?? '0'),
                                    _buildTableRow('In Waiting:', project.remainingGoal?.toString() ?? '0'),
                                    _buildTableRow('Duration:', project.projectDurationViewer?.toString() ?? 'N/A'),
                                    _buildTableRow('Min. Investment:', project.minInvestmentAmount ?? 'N/A'),
                                    _buildTableRow('Projected:', project.projected ?? 'N/A'),
                                    _buildTableRow('ROI:', project.annualRoi != null ? '${project.annualRoi}% annually' : 'N/A'),
                                    TableRow(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 4),
                                          child: Text('Project Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Text(
                                            project.status == 1 ? 'Running' : 'Closed',
                                            style: TextStyle(
                                              color: project.status == 1 ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // const SizedBox(height: 10),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 10),
                            //   child: SizedBox(
                            //     width: double.infinity,
                            //     height: 38,
                            //     child: ElevatedButton(
                            //       onPressed: null, // Completed project - no action
                            //       style: ElevatedButton.styleFrom(
                            //         backgroundColor: Colors.grey.shade600,
                            //         padding: const EdgeInsets.symmetric(vertical: 8),
                            //       ),
                            //       child: const Text(
                            //         'Completed',
                            //         style: TextStyle(color: Colors.white, fontSize: 14),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      )
          : null,
    );
  }
}
