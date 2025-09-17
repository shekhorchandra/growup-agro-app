class DepositResponseModel {
  final bool success;
  final String message;
  final List<DepositHistory>? data;  // Nullable list for GET history
  final DepositHistory? singleDeposit; // Nullable single deposit for POST response

  DepositResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.singleDeposit,
  });

  factory DepositResponseModel.fromJson(Map<String, dynamic> json) {
    // If "data" is a list (GET)
    if (json['data'] is List) {
      return DepositResponseModel(
        success: json['success'] ?? false,
        message: json['message']?.toString() ?? '',
        data: (json['data'] as List)
            .map((item) => DepositHistory.fromJson(item))
            .toList(),
        singleDeposit: null,
      );
    }
    // If "data" is an object (POST)
    else if (json['data'] is Map) {
      return DepositResponseModel(
        success: json['success'] ?? false,
        message: json['message']?.toString() ?? '',
        data: null,
        singleDeposit: DepositHistory.fromJson(json['data']),
      );
    }
    // fallback if no data or unexpected format
    else {
      return DepositResponseModel(
        success: json['success'] ?? false,
        message: json['message']?.toString() ?? '',
        data: null,
        singleDeposit: null,
      );
    }
  }
}

class DepositHistory {
  final int? id;
  final int? investorId;
  final int invoiceNo;
  final String amount;
  final String paymentMethod;
  final String? bankName;
  final String? bankPaymentSlip;
  final String? mobileNumber;
  final String? mobileTransactionId;
  final String status;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DepositHistory({
    this.id,
    this.investorId,
    required this.invoiceNo,
    required this.amount,
    required this.paymentMethod,
    this.bankName,
    this.bankPaymentSlip,
    this.mobileNumber,
    this.mobileTransactionId,
    required this.status,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory DepositHistory.fromJson(Map<String, dynamic> json) {
    return DepositHistory(
      id: json['id'],
      investorId: json['investor_id'],
      invoiceNo: json['invoice_no'] ?? 0,
      amount: json['amount']?.toString() ?? '0',
      paymentMethod: json['payment_method'] ?? '',
      bankName: json['bank_name'],
      bankPaymentSlip: json['bank_payment_slip'],
      mobileNumber: json['mobile_number'],
      mobileTransactionId: json['mobile_transaction_id'],
      status: json['status'] ?? '',
      note: json['note'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}
