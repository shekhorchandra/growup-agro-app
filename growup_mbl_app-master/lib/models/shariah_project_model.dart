class ShariahProject {
  final String? imageUrl;
  final String? name;
  final String? investmentType_name;
  final int? id;
  final int? remaining_opportunity_days;
  final String? investmentGoal;
  final int? raised;
  final int? remaining_goal;
  final String? project_duration_viewer;
  final String? minInvestmentAmount;
  final String? projected;
  final int? annualRoi;
  // final String? image;
  final int? status;
  final String? projectName;

  ShariahProject({
    this.imageUrl,
    this.name,
    this.investmentType_name,
    this.id,
    this.remaining_opportunity_days,
    this.investmentGoal,
    this.raised,
    this.remaining_goal,
    this.project_duration_viewer,
    this.minInvestmentAmount,
    this.projected,
    this.annualRoi,
    // this.image,
    this.status,
    this.projectName,
  });

  factory ShariahProject.fromJson(Map<String, dynamic> json) {
    return ShariahProject(
      name: json['name'] ?? json['project_name'], // fallback if 'name' missing
      id: json['id'],
      remaining_opportunity_days: json['remaining_opportunity_days'] == null
          ? null
          : int.tryParse(json['remaining_opportunity_days'].toString()) ?? 0,

      investmentGoal: json['investment_goal'],
      raised: json['raised'],
      remaining_goal: json['remaining_goal'],
      project_duration_viewer: json['project_duration_viewer'],
      minInvestmentAmount: json['min_investment_amount'],
      projected: json['projected'],
      annualRoi: json['annual_roi'],
      imageUrl: json['image_url'],
      status: json['status'],
      projectName: json['project_name'],
      investmentType_name: json['investmentType_name'],
    );
  }

}
