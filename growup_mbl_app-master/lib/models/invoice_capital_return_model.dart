class CapitalReturn {
  final String projectName;
  final String projectCode;
  final String projectCategory;
  final String invoiceNo;
  final String amountInvested;
  final String capitalReturn;
  final String currency;
  final String viewInvoiceUrl;
  final String downloadInvoiceUrl;

  CapitalReturn({
    required this.projectName,
    required this.projectCode,
    required this.projectCategory,
    required this.invoiceNo,
    required this.amountInvested,
    required this.capitalReturn,
    required this.currency,
    required this.viewInvoiceUrl,
    required this.downloadInvoiceUrl,
  });

  factory CapitalReturn.fromJson(Map<String, dynamic> json) {
    return CapitalReturn(
      projectName: json['project_name'] ?? '',
      projectCode: json['project_code'] ?? '',
      projectCategory: json['project_category'] ?? '',
      invoiceNo: json['invoice_no'] ?? '',
      amountInvested: json['amount_invested'] ?? '0',
      capitalReturn: json['capital_return'] ?? '0',
      currency: json['currency'] ?? 'BDT',
      viewInvoiceUrl: json['view_invoice_url'] ?? '',
      downloadInvoiceUrl: json['download_invoice_url'] ?? '',
    );
  }
}
