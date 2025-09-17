class Investor {
  final int id;
  final String name;
  final String code;

  Investor({required this.id, required this.name, required this.code});

  factory Investor.fromJson(Map<String, dynamic> json) {
    return Investor(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class ProjectCertificate {
  final int projectId;
  final String projectName;
  final String businessType;
  final String investmentAmount;
  final String startDate;
  final String endDate;
  final double annualRoi;
  final String issuedOn;
  final String shareLink;
  final String whatsappUrl;
  final String facebookUrl;

  ProjectCertificate({
    required this.projectId,
    required this.projectName,
    required this.businessType,
    required this.investmentAmount,
    required this.startDate,
    required this.endDate,
    required this.annualRoi,
    required this.issuedOn,
    required this.shareLink,
    required this.whatsappUrl,
    required this.facebookUrl,
  });

  factory ProjectCertificate.fromJson(Map<String, dynamic> json) {
    return ProjectCertificate(
      projectId: json['project_id'],
      projectName: json['project_name'],
      businessType: json['business_type'],
      investmentAmount: json['investment_amount'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      annualRoi: (json['annual_roi'] as num).toDouble(),
      issuedOn: json['issued_on'],
      shareLink: json['share_link'],
      whatsappUrl: json['whatsapp_url'],
      facebookUrl: json['facebook_url'],
    );
  }
}
