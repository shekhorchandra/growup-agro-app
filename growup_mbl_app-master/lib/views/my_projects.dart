import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growup_agro/models/my_projects_model.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:growup_agro/views/project_Descriotion_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyProjectsPage(),
    );
  }
}

class MyProjectsPage extends StatefulWidget {
  final bool hideAppBar;
  const MyProjectsPage({super.key, this.hideAppBar = false});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  Set<int> _loadingProjectIds = {};
  late Future<List<MyProjectsModel>> futureMyProjectsModel;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _showBackToTopButton = false;
  List<MyProjectsModel> _allProjects = [];
  List<MyProjectsModel> _filteredProjects = [];

  @override
  void initState() {
    super.initState();
    futureMyProjectsModel = fetchMyProjectsModel();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredProjects = _allProjects
            .where((project) =>
        project.projectName?.toLowerCase().contains(query) ?? false)
            .toList();
      });
    });

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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<List<MyProjectsModel>> fetchMyProjectsModel() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final investorIdString = prefs.getString('investor_id');

    if (token == null || investorIdString == null) {
      throw Exception('Token or Investor ID not found');
    }

    final investorId = int.tryParse(investorIdString);
    if (investorId == null) {
      throw Exception('Invalid investor ID');
    }

    final url = Uri.parse(ApiConstants.investorProjectList(investorId.toString()));

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic>? projectList = decoded['data'];

      if (projectList == null || projectList.isEmpty) {
        throw Exception('No My Projects found.');
      }

      return projectList
          .map<MyProjectsModel>((project) => MyProjectsModel.fromJson(project))
          .toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }


  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            value,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
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
          'My Projects',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<MyProjectsModel>>(
        future: futureMyProjectsModel,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error} '));
          }

          if (snapshot.hasData) {
            _allProjects = snapshot.data!;
            _filteredProjects = _searchController.text.isEmpty
                ? _allProjects
                : _allProjects
                .where((project) => project.projectName
                ?.toLowerCase()
                .contains(_searchController.text.toLowerCase()) ??
                false)
                .toList();

            return Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              if (project.image != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 160,
                                    child: Image.network(
                                      'https://admin-growup.onebitstore.site${project.image}',
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
                                  project.projectName ?? "N/A",
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
                                      _buildTableRow('Project Name:', project.projectName ?? 'N/A'),
                                      _buildTableRow('Business Type:', project.businessTypeName ?? 'N/A'),
                                      _buildTableRow('Project Duration:', project.projectDurationViewer ?? 'N/A'),
                                      _buildTableRow('Projected:', project.projected ?? 'N/A'),
                                      _buildTableRow('Min. Investment:', project.minInvestmentAmount ?? 'N/A'),
                                      _buildTableRow('ROI:', project.annualRoi != null ? 'Annually ${project.annualRoi}%' : 'N/A'),
                                      _buildTableRow('Investment Goal:', project.investmentGoal ?? 'N/A'),
                                      _buildTableRow('Raised:', project.totalInvestment ?? 'N/A'),
                                      _buildTableRow('Investment Time:', '${project.investmentOpportunityDays ?? 'N/A'} days'),
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
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 38,
                                  child: ElevatedButton(
                                    onPressed: _loadingProjectIds.contains(project.id)
                                        ? null
                                        : () async {
                                      final projectId = project.id;
                                      if (projectId == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Project ID is missing')),
                                        );
                                        return;
                                      }

                                      setState(() {
                                        _loadingProjectIds.add(projectId);
                                      });

                                      try {
                                        final prefs = await SharedPreferences.getInstance();
                                        final investorCode = prefs.getString('investor_code');
                                        if (investorCode == null || investorCode.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Investor code not found.')),
                                          );
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProjectDescriptionPage(
                                              projectId: projectId,
                                              investorCode: investorCode,
                                            ),
                                          ),
                                        );
                                      } finally {
                                        setState(() {
                                          _loadingProjectIds.remove(projectId);
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFAECC00),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    child: _loadingProjectIds.contains(project.id)
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                        : const Text(
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
          }

          return const Center(child: Text('No My Projects found.'));
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
