class InvestmentHistoryItem {
  final int project_id;
  final String? projectTitle;
  final String? projectCategory;
  final String? firstInvestmentDate;
  final int? totalInvestment;
  final int investmentCount;
  final double? projectProgress;
  final String status;
  final String? projectImage;
  final double? roiDetails;
  final double? capitalReturnDetails;


  InvestmentHistoryItem({
    required this.project_id,
    this.projectTitle,
    this.projectCategory,
    required this.firstInvestmentDate,
    required this.totalInvestment,
    required this.investmentCount,
    required this.projectProgress,
    required this.status,
    required this.roiDetails,
    required this.capitalReturnDetails,
    required this.projectImage,
  });

  factory InvestmentHistoryItem.fromJson(Map<String, dynamic> json) {
    return InvestmentHistoryItem(
      projectImage: json['project_image'],
      project_id: json['project_id'],
      projectTitle: json['project_title'],
      projectCategory: json['project_category'],
      firstInvestmentDate: json['first_investment_date'],
      totalInvestment: json['total_investment'],
      investmentCount: json['investment_count'],
      projectProgress: (json['project_progress'] as num?)?.toDouble(),
      status: json['status'],
      roiDetails: (json['roi_details'] as num?)?.toDouble(),
      capitalReturnDetails: (json['capital_return_details'] as num?)?.toDouble(),
    );
  }
}
