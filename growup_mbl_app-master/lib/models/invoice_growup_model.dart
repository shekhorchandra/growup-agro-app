class GrowupInvoice {
  final int investmentId;
  final String invoiceNo;
  final String amount;
  final String createdAt;
  final Project project;

  GrowupInvoice({
    required this.investmentId,
    required this.invoiceNo,
    required this.amount,
    required this.createdAt,
    required this.project,
  });

  factory GrowupInvoice.fromJson(Map<String, dynamic> json) {
    return GrowupInvoice(
      investmentId: json['investment_id'],
      invoiceNo: json['invoice_no'] ?? '',
      amount: json['amount'] ?? '0.00',
      createdAt: json['created_at'] ?? '',
      project: Project.fromJson(json['project']),
    );
  }
}

class Project {
  final int id;
  final String name;
  final String code;
  final String category;

  Project({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
