
import 'package:flutter/material.dart';
import 'package:growup_agro/views/long_duration.dart';
import 'package:growup_agro/views/shariah.dart';
import 'package:growup_agro/views/short_duration.dart';
import 'package:growup_agro/views/upcoming_projects.dart';

import 'completed_projects.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AllProjectsPage(),
    );
  }
}

class AllProjectsPage extends StatefulWidget {
  const AllProjectsPage({Key? key}) : super(key: key);

  @override
  _AllProjectsPageState createState() => _AllProjectsPageState();
}

class _AllProjectsPageState extends State<AllProjectsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //centerTitle: true,
        //backgroundColor: const Color(0xFF2E7D32),
        // foregroundColor: Colors.white,

        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          'All Projects',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Selected tab style
          unselectedLabelStyle: const TextStyle(fontSize: 16), // Unselected tab style
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [

            Tab(text: 'Live'),
            Tab(text: 'Long'),
            Tab(text: 'Short'),
            Tab(text: 'Coming'),
            Tab(text: 'Closed'),
          ],
        )

      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          const ShariahProjectsPage(hideAppBar: true), // Your existing Shariah projects page widget
          const LongProjectsPage(hideAppBar: true),    // Your existing Long projects page widget
          const ShortProjectsPage(hideAppBar: true),   // Your existing Short projects page widget
          const UpcomingProjectsPage(hideAppBar: true),
          const CompletedProjectsPage(hideAppBar: true),
        ],
      ),
    );
  }
}

