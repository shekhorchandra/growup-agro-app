class RoiInvoice {
  final String projectName;
  final String projectCategory;
  final String projectCode;
  final String invoiceNo;
  final String totalRoi;
  final String amountInvested;
  final String currency;

  RoiInvoice({
    required this.projectName,
    required this.projectCategory,
    required this.projectCode,
    required this.invoiceNo,
    required this.totalRoi,
    required this.amountInvested,
    required this.currency,
  });

  factory RoiInvoice.fromJson(Map<String, dynamic> json) {
    return RoiInvoice(
      projectName: json['project_name'] ?? '',
      projectCategory: json['project_category'] ?? '',
      projectCode: json['project_code'] ?? '',
      invoiceNo: json['invoice_no'] ?? '',
      totalRoi: json['total_roi'] ?? '',
      amountInvested: json['amount_invested'] ?? '',
      currency: json['currency'] ?? '',
    );
  }
}
