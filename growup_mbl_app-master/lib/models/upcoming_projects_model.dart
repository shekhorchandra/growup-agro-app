class UpcomingProject {
  final int id;
  final String projectName;
  final String? imageUrl;
  final int remainingOpportunityDays;
  final String investmentGoal;
  final num raised;
  final num remainingGoal;
  final int? projectDurationViewer;
  final String minInvestmentAmount;
  final String? projected;
  final int annualRoi;
  final int status;

  UpcomingProject({
    required this.id,
    required this.projectName,
    this.imageUrl,
    required this.remainingOpportunityDays,
    required this.investmentGoal,
    required this.raised,
    required this.remainingGoal,
    required this.projectDurationViewer,
    required this.minInvestmentAmount,
    this.projected,
    required this.annualRoi,
    required this.status,
  });

  factory UpcomingProject.fromJson(Map<String, dynamic> json) {
    return UpcomingProject(
      id: json['id'],
      projectName: json['project_name'] ?? 'N/A',
      imageUrl: json['image_url'],
      remainingOpportunityDays: json['remaining_opportunity_days'] ?? 0,
      investmentGoal: json['investment_goal'] ?? '0',
      raised: json['raised'] ?? 0,
      remainingGoal: json['remaining_goal'] ?? 0,
      projectDurationViewer: json['project_duration_viewer'],
      minInvestmentAmount: json['min_investment_amount'] ?? '0',
      projected: json['projected'],
      annualRoi: json['annual_roi'] ?? 0,
      status: json['status'] ?? 0,
    );
  }
}