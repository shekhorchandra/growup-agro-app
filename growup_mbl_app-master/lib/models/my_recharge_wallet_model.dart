// class TransactionModel {
//   final int id;
//   final int invoiceNo;
//   final int? projectId;
//   final String trxId;
//   final int walletId;
//   final String type;
//   final String? amount;
//   final String direction;
//   final int creditAccountId;
//   final int debitAccountId;
//   final String? note;
//   final int? rechargeId;
//   final int? depositRequestId;
//   final int? withdrawRequestId;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   TransactionModel({
//     required this.id,
//     required this.invoiceNo,
//     this.projectId,
//     required this.trxId,
//     required this.walletId,
//     required this.type,
//     this.amount,
//     required this.direction,
//     required this.creditAccountId,
//     required this.debitAccountId,
//     this.note,
//     this.rechargeId,
//     this.depositRequestId,
//     this.withdrawRequestId,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory TransactionModel.fromJson(Map<String, dynamic> json) {
//     return TransactionModel(
//       id: json['id'] ?? 0,
//       invoiceNo: json['invoice_no'] ?? 0,
//       projectId: json['project_id'],
//       trxId: json['trx_id'] ?? '',
//       walletId: json['wallet_id'] ?? 0,
//       type: json['type'] ?? '',
//       amount: json['amount'],
//       direction: json['direction'] ?? '',
//       creditAccountId: json['credit_account_id'] ?? 0,
//       debitAccountId: json['debit_account_id'] ?? 0,
//       note: json['note'],
//       rechargeId: json['recharge_id'],
//       depositRequestId: json['deposit_request_id'],
//       withdrawRequestId: json['withdraw_request_id'],
//       createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
//       updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'invoice_no': invoiceNo,
//       'project_id': projectId,
//       'trx_id': trxId,
//       'wallet_id': walletId,
//       'type': type,
//       'amount': amount,
//       'direction': direction,
//       'credit_account_id': creditAccountId,
//       'debit_account_id': debitAccountId,
//       'note': note,
//       'recharge_id': rechargeId,
//       'deposit_request_id': depositRequestId,
//       'withdraw_request_id': withdrawRequestId,
//       'created_at': createdAt?.toIso8601String(),
//       'updated_at': updatedAt?.toIso8601String(),
//     };
//   }
// }
