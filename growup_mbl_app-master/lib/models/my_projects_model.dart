class MyProjectsModel {
  final int? id;
  final String? projectName;
  final String? projectDurationViewer;
  final String? minInvestmentAmount;
  final String? investmentGoal;
  final String? totalInvestment;
  final int? annualRoi;
  final int? status;
  final String? image;
  final String? projected;
  final int? investmentOpportunityDays;
  final String? businessTypeName;

  MyProjectsModel({
    this.id,
    this.projectName,
    this.projectDurationViewer,
    this.minInvestmentAmount,
    this.investmentGoal,
    this.totalInvestment,
    this.annualRoi,
    this.status,
    this.image,
    this.projected,
    this.investmentOpportunityDays,
    this.businessTypeName,
  });

  factory MyProjectsModel.fromJson(Map<String, dynamic> json) {
    return MyProjectsModel(
      id: json['id'],
      projectName: json['project_name'],
      projectDurationViewer: json['project_duration_viewer'],
      minInvestmentAmount: json['min_investment_amount'],
      investmentGoal: json['investment_goal'],
      totalInvestment: json['total_investment'],
      annualRoi: json['annual_roi'],
      status: json['status'],
      image: json['image_url'],
      projected: json['projected'],
      investmentOpportunityDays: json['investment_opportunity_days'],
      businessTypeName: json['business_type']?['name'], // nested object
    );
  }
}
