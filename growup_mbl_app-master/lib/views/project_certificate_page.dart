import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:growup_agro/views/fullscreen_image_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/project_certificate_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectCertificatePage extends StatefulWidget {
  const ProjectCertificatePage({Key? key}) : super(key: key);

  @override
  State<ProjectCertificatePage> createState() => _ProjectCertificatePageState();
}

class _ProjectCertificatePageState extends State<ProjectCertificatePage> {
  late Future<List<ProjectCertificate>> _certificates;
  late Investor _investor;

  // Pagination variables
  int _currentPage = 0;
  final int _itemsPerPage = 3;

  @override
  void initState() {
    super.initState();
    _certificates = fetchCertificates();
  }

  // ... fetchCertificates() remains the same
  Future<List<ProjectCertificate>> fetchCertificates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final investorCode = prefs.getString('investor_code') ?? '';

      final url = Uri.parse(
        'https://admin-growup.onebitstore.site/api/project-certificates',
      );

      final response = await http.get(
        url.replace(queryParameters: {"investor_code": investorCode}),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Set investor info
        _investor = Investor.fromJson(data['investor']);

        final projects = (data['projects'] as List)
            .map((e) => ProjectCertificate.fromJson(e))
            .toList();

        return projects;
      } else {
        throw Exception('Failed to load project certificates');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch certificates');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Investment Certificate",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ProjectCertificate>>(
        future: _certificates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No certificates found'));
          }

          final projects = snapshot.data!;
          final totalPages = (projects.length / _itemsPerPage).ceil();

          // Paginated items
          final paginatedProjects = projects
              .skip(_currentPage * _itemsPerPage)
              .take(_itemsPerPage)
              .toList();

          return Column(
            children: [
              // Scrollable content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Certificate of Investment",
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black,),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "This is to certify that",
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _investor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF4BD06),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "has invested all this project(s):",
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Project Cards
                    ...paginatedProjects.map((project) => _buildProjectCard(project)).toList(),
                  ],
                ),
              ),

              // Pagination (Fixed Footer)
              if (totalPages > 1)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  // color: Colors.white,
                  child: Row(
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
                        'Page ${_currentPage + 1} of $totalPages',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _currentPage < totalPages - 1
                            ? () => setState(() => _currentPage++)
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

// Move your project card code to a separate method
  Widget _buildProjectCard(ProjectCertificate project) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFF4BD06), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Clickable image
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageView(imagePath: 'assets/images/certificate.png'),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Image.asset(
                'assets/images/certificate.png',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  project.projectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF4BD06),
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    text: "Business Type: ",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: project.businessType,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: "Investment Amount: ",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: project.investmentAmount,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Text("Start Date: ${project.startDate}"),
                Text("End Date: ${project.endDate}"),
                Text("Annual ROI: ${project.annualRoi}%"),
                Text("Issued on: ${project.issuedOn}"),
                const SizedBox(height: 8),

                Divider(color: Colors.grey.shade300),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share, color: Colors.black, size: 14),
                    const SizedBox(width: 4),
                    const Text(
                      "Share",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Copy Link
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(project.shareLink);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.share, color: Colors.white, size: 14),
                      label: const Text(
                        "Copy Link",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // WhatsApp
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(project.whatsappUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 14),
                      label: const Text(
                        "WhatsApp",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Facebook
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(project.facebookUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.facebookF, color: Colors.white, size: 14),
                      label: const Text(
                        "Facebook",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

