import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/upcoming_projects_model.dart';
import 'project_Descriotion_page.dart';

class UpcomingProjectsPage extends StatefulWidget {
  final bool hideAppBar;
  const UpcomingProjectsPage({super.key, this.hideAppBar = false});

  @override
  State<UpcomingProjectsPage> createState() => _UpcomingProjectsPageState();
}

class _UpcomingProjectsPageState extends State<UpcomingProjectsPage> {
  Set<int> _loadingProjectIds = {};
  late Future<List<UpcomingProject>> futureUpcomingProjects;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  List<UpcomingProject> _allProjects = [];
  List<UpcomingProject> _filteredProjects = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureUpcomingProjects = fetchUpcomingProjects();
    _searchController.addListener(_onSearchChanged);

    _scrollController.addListener(() {
      if (_scrollController.offset >= 300) {
        if (!_showBackToTopButton) {
          setState(() => _showBackToTopButton = true);
        }
      } else {
        if (_showBackToTopButton) {
          setState(() => _showBackToTopButton = false);
        }
      }
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProjects = _allProjects.where((project) {
        return project.projectName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  Future<List<UpcomingProject>> fetchUpcomingProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final investorCode = prefs.getString('investor_code') ?? '';

    // final url = Uri.parse('https://admin-growup.onebitstore.site/api/upcoming-projects?investor_code=$investorCode');
    // final response = await http.get(url, headers: {
    //   'Authorization': 'Bearer $token',
    //   'Accept': 'application/json',
    // });
    final url = Uri.parse(ApiConstants.completedProjects(investorCode));

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> projectsJson = data['projects'];
      _allProjects = projectsJson.map((json) => UpcomingProject.fromJson(json)).toList();
      _filteredProjects = _allProjects;
      return _allProjects;
    } else {
      throw Exception('Failed to load upcoming projects');
    }
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(value),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideAppBar
          ? null
          : AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Upcoming Projects', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<UpcomingProject>>(
        future: futureUpcomingProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No upcoming projects found.'));
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
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = _filteredProjects[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 160,
                                  child: Image.network(
                                    project.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                      'assets/images/placeholder1.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                project.projectName,
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
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
                                    _buildTableRow('Remaining Days:', project.remainingOpportunityDays.toString()),
                                    _buildTableRow('Goal:', project.investmentGoal),
                                    _buildTableRow('Raised:', project.raised.toString()),
                                    _buildTableRow('Remaining:', project.remainingGoal.toString()),
                                    _buildTableRow('Duration:', project.projectDurationViewer?.toString() ?? 'N/A'),
                                    _buildTableRow('Min Investment:', project.minInvestmentAmount),
                                    _buildTableRow('Projected:', project.projected ?? 'N/A'),
                                    _buildTableRow('Annual ROI:', '${project.annualRoi}%'),
                                    _buildTableRow('Status:', project.status.toString()),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: SizedBox(
                                width: double.infinity,
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFAECC00),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  child: const Text(
                                    'Invest Now',
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
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
