class WalletHistoryModel {
  final int id;
  final int invoiceNo;
  final int? projectId;
  final String trxId;
  final int walletId;
  final String type;
  final double amount;
  final String direction;
  final int? creditAccountId;
  final int? debitAccountId;
  final String? note;
  final int? rechargeId;
  final int? depositRequestId;
  final int? withdrawRequestId;
  final String createdAt;
  final String updatedAt;
  final String? status;

  WalletHistoryModel({
    required this.id,
    required this.invoiceNo,
    this.projectId,
    required this.trxId,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.direction,
    this.creditAccountId,
    this.debitAccountId,
    this.note,
    this.rechargeId,
    this.depositRequestId,
    this.withdrawRequestId,
    required this.createdAt,
    required this.updatedAt,
    this.status,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    return WalletHistoryModel(
      id: json['id'] ?? 0,
      invoiceNo: json['invoice_no'] ?? 0,
      projectId: json['project_id'],
      trxId: json['trx_id']?.toString() ?? '',
      walletId: json['wallet_id'] ?? 0,
      type: json['type']?.toString() ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      direction: json['direction']?.toString() ?? '',
      creditAccountId: json['credit_account_id'],
      debitAccountId: json['debit_account_id'],
      note: json['note']?.toString(),
      rechargeId: json['recharge_id'],
      depositRequestId: json['deposit_request_id'],
      withdrawRequestId: json['withdraw_request_id'],
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      status: json['status']?.toString(),
    );
  }
}
