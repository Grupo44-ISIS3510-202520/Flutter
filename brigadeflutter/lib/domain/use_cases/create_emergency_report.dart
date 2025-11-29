import '../../helpers/errors/failures.dart';
import '../../helpers/utils/id_generator.dart';
import '../../helpers/utils/validators.dart';
import '../../data/entities/report.dart';
import '../../data/repositories/report_repository.dart';

class CreateEmergencyReport {
  CreateEmergencyReport(this.repo, this.idGen);
  final ReportRepository repo;
  final FirestoreIdGenerator idGen;

  Future<String> call({
    String? reportId,
    required String type,
    required String place,
    required String description,
    required bool isFollowUp,
    required int elapsedTime,
    double? latitude,
    double? longitude,
    String? audioUrl,
    String? imageUrl,
    required int uiid,
    required String userId,
    required bool isOnline,
  }) async {
    final Iterable<String> errors = <String?>[
      validateType(type),
      validatePlace(place),
      validateDescription(description),
    ].whereType<String>();
    if (errors.isNotEmpty) {
      throw ValidationFailure(errors.first);
    }

    final String newReportId = reportId ??
        (isOnline
            ? 'F${await idGen.nextReportId()}'
            : 'F${DateTime.now().millisecondsSinceEpoch}');
    
    final Report report = Report(
      reportId: newReportId,
      type: type.trim(),
      description: description.trim(),
      isFollowUp: isFollowUp,
      timestamp: DateTime.now(),
      elapsedTime: elapsedTime,
      place: place.trim(),
      latitude: latitude,
      longitude: longitude,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
      uiid: uiid,
      userId: userId,
    );

    if (isOnline) {
      await repo.create(report);
    } else {
      await repo.enqueue(report);
    }
    return newReportId;
  }
}
