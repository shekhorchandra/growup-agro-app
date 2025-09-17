class totalRoiDetail {
  final String projectName;
  final double totalRoi;

  totalRoiDetail({required this.projectName, required this.totalRoi});

  factory totalRoiDetail.fromJson(Map<String, dynamic> json) {
    return totalRoiDetail(
      projectName: json['project_name'] ?? 'N/A',
      totalRoi: (json['total_roi'] as num).toDouble(),
    );
  }
}