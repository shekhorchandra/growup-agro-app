// class InvestmentDetailItem {
//   final int? id;
//   final int? projectId;
//   final int? investorId;
//   final String? amount;
//   final String? investmentDate;
//   final String? invoiceNo;
//   final int? investmentMedia;
//   final int? roiDisbursement;
//   final int? runRoiCalc;
//   final String? createdAt;
//   final String? updatedAt;
//
//   InvestmentDetailItem({
//     this.id,
//     this.projectId,
//     this.investorId,
//     this.amount,
//     this.investmentDate,
//     this.invoiceNo,
//     this.investmentMedia,
//     this.roiDisbursement,
//     this.runRoiCalc,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory InvestmentDetailItem.fromJson(Map<String, dynamic> json) {
//     return InvestmentDetailItem(
//       id: json['id'] as int?,
//       projectId: json['project_id'] as int?,
//       investorId: json['investor_id'] as int?,
//       amount: json['amount']?.toString(),
//       investmentDate: json['investment_date']?.toString(),
//       invoiceNo: json['invoice_no']?.toString(),
//       investmentMedia: json['investment_media'] as int?,
//       roiDisbursement: json['roi_disbursement'] as int?,
//       runRoiCalc: json['run_roi_calc'] as int?,
//       createdAt: json['created_at']?.toString(),
//       updatedAt: json['updated_at']?.toString(),
//     );
//   }
// }
