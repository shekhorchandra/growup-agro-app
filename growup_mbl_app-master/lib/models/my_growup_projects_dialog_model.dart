
class Project {
  final String projectName;
  final int totalInvestment;

  Project({required this.projectName, required this.totalInvestment});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectName: json['project_name'] ?? 'Unknown',
      totalInvestment: json['total_investment'] ?? 0,
    );
  }
}
