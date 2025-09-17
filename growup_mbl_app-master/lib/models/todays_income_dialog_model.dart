class RoiDetail {
  final double totalRoi;
  final String projectName;
  final String createdAt;

  RoiDetail({
    required this.totalRoi,
    required this.projectName,
    required this.createdAt,
  });

  factory RoiDetail.fromJson(Map<String, dynamic> json) {
    return RoiDetail(
      totalRoi: (json['total_roi'] as num).toDouble(),
      projectName: json['project']['project_name'] ?? 'N/A',
      createdAt: json['project']['created_at'] ?? '',
    );
  }
}