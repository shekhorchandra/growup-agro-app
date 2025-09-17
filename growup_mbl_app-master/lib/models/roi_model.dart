class RoiModel {
  final int id;
  final int projectId;
  final int investorId;
  final double roiAmount;
  final String countingDate;
  final String createdAt;

  RoiModel({
    required this.id,
    required this.projectId,
    required this.investorId,
    required this.roiAmount,
    required this.countingDate,
    required this.createdAt,
  });

  factory RoiModel.fromJson(Map<String, dynamic> json) {
    return RoiModel(
      id: json['id'],
      projectId: json['project_id'],
      investorId: json['investor_id'],
      roiAmount: (json['roi_amount'] as num).toDouble(),
      countingDate: json['counting_date'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
