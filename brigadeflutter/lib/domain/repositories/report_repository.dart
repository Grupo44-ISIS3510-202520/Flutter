abstract class ReportRepository {
  Future<void> createEmergencyReport({
    required String type,
    required String placeTime,
    required String description,
    required bool isFollowUp,
    String protocolQuery = '',
    double? latitude,
    double? longitude,
    String? userId,
    DateTime? createdAt,
  });
}
