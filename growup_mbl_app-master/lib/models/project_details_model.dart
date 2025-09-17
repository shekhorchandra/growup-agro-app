class ProjectDetailsModel {
  final String projectName;
  final String projectCode;
  final String projectCategoryName;
  final String businessTypeName;
  final String investmentGoal;
  final int? minInvestmentAmount;
  final String annualRoi;
  final String projectDurationViewer;
  final String riskFactor;
  final String roiStartDate;
  final String imageUrl;
  final String overviewHtml;
  final String projected;
  final int rasied;
  final int status;
  final int investment_time;
  final int in_waiting;
  final List<Map<String, dynamic>> keyPointsData;
  final List<Map<String, dynamic>> securityInformation;

  ProjectDetailsModel({
    required this.projectName,
    required this.projectCode,
    required this.projectCategoryName,
    required this.businessTypeName,
    required this.investmentGoal,
    required this.minInvestmentAmount,
    required this.annualRoi,
    required this.projectDurationViewer,
    required this.riskFactor,
    required this.roiStartDate,
    required this.imageUrl,
    required this.status,
    required this.projected,
    required this.rasied,
    required this.investment_time,
    required this.in_waiting,
    required this.overviewHtml,
    required this.keyPointsData,
    required this.securityInformation,
  });

  factory ProjectDetailsModel.fromJson(Map<String, dynamic> data) {
    final project = data['project'] ?? {};
    final details = project['project_detail'] ?? {};

    return ProjectDetailsModel(
      projectName: project['project_name']?.toString() ?? 'N/A',
      projectCode: project['project_code']?.toString() ?? 'N/A',
      projectCategoryName: project['projectCategory_name']?.toString() ?? 'N/A',
      businessTypeName: project['businessType_name']?.toString() ?? 'N/A',
      investmentGoal: project['investment_goal']?.toString() ?? 'N/A',
      minInvestmentAmount: double.tryParse(
          project['min_investment_amount']?.toString().replaceAll(',', '') ?? ''
      )?.toInt() ?? 0,
      annualRoi: project['annual_roi']?.toString() ?? 'N/A',
      projectDurationViewer: project['project_duration_viewer']?.toString() ?? 'N/A',
      riskFactor: project['risk_factor']?.toString() ?? 'N/A',
      roiStartDate: project['roi_start_date']?.toString() ?? 'N/A',
      imageUrl: (data['image_url'] ?? project['image_url'])?.toString() ?? '',
      overviewHtml: (data['overview'] ?? details['project_overview'])?.toString() ?? '',
      projected: project['projected']?.toString() ?? 'N/A',
      rasied: int.tryParse(
          data['rasied']?.toString().replaceAll(',', '').split('.').first ?? ''
      ) ?? 0,

      status: int.tryParse(project['status']?.toString() ?? '') ?? 0,
      investment_time: int.tryParse(data['investment_time']?.toString() ?? '') ?? 0,
      in_waiting: int.tryParse(
          data['in_waiting']?.toString().replaceAll(',', '').split('.').first ?? ''
      ) ?? 0,

      keyPointsData: List<Map<String, dynamic>>.from(data['keyPointsData'] ?? []),
      securityInformation: List<Map<String, dynamic>>.from(data['security_information'] ?? []),
    );
  }
}
