class TaxCertificate {
  late final String investorName;
  final String startFiscalYear;
  final String endFiscalYear;
  final List<ProjectDetail> projectDetails;
  final double roiTotal;
  final double tax;
  final double netRoi;
  final String issuedOn;
  final String downloadLink;

  TaxCertificate({
    required this.investorName,
    required this.startFiscalYear,
    required this.endFiscalYear,
    required this.projectDetails,
    required this.roiTotal,
    required this.tax,
    required this.netRoi,
    required this.issuedOn,
    required this.downloadLink,
  });

  factory TaxCertificate.fromJson(Map<String, dynamic> json, String investorName) {
    return TaxCertificate(
      investorName: investorName,
      startFiscalYear: json['fiscal_year']['start'],
      endFiscalYear: json['fiscal_year']['end'],
      projectDetails: (json['project_details'] as List)
          .map((e) => ProjectDetail.fromJson(e))
          .toList(),
      roiTotal: (json['roi_total'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      netRoi: (json['net_roi'] as num).toDouble(),
      issuedOn: json['issued_on'],
      downloadLink: json['download_link'],
    );
  }
}

class ProjectDetail {
  final String name;
  final String matureDate;
  final double roiAmount;
  final double tax;
  final double netRoi;

  ProjectDetail({
    required this.name,
    required this.matureDate,
    required this.roiAmount,
    required this.tax,
    required this.netRoi,
  });

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    return ProjectDetail(
      name: json['project']['name'],
      matureDate: json['project']['mature_date'],
      roiAmount: (json['roi_amount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      netRoi: (json['net_roi'] as num).toDouble(),
    );
  }
}
