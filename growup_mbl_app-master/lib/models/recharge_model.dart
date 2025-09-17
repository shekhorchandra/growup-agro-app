class Recharge {
  final int sl;
  final String date;
  final String amount;
  final String method;
  final String status;
  final String note;
  final String? invoiceUrl;
  final String? invoiceDownloadUrl;

  Recharge({
    required this.sl,
    required this.date,
    required this.amount,
    required this.method,
    required this.status,
    required this.note,
    this.invoiceUrl,
    this.invoiceDownloadUrl,
  });

  factory Recharge.fromJson(Map<String, dynamic> json) {
    return Recharge(
      sl: json['sl'] ?? 0,
      date: json['date'] ?? '',
      amount: json['amount'] ?? '',
      method: json['method'] ?? '',
      status: json['status'] ?? '',
      note: json['note'] ?? '',
      invoiceUrl: json['invoice_url'],
      invoiceDownloadUrl: json['invoice_download_url'],
    );
  }
}
