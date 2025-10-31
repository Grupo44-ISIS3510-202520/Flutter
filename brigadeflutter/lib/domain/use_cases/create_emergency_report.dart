import '../../core/errors/failures.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/id_generator.dart';
import '../../data/entities/report.dart';
import '../../data/repositories/report_repository.dart';

class CreateEmergencyReport {
  final ReportRepository repo;
  final FirestoreIdGenerator idGen;
  CreateEmergencyReport(this.repo, this.idGen);

  Future<int> call({
    int? id,
    required String type,
    required String placeTime,
    required String description,
    required bool isFollowUp,
    double? latitude,
    double? longitude,
    required bool isOnline,
  }) async {
    final errors = [
      validateType(type),
      validatePlaceTime(placeTime),
      validateDescription(description),
    ].whereType<String>();
    if (errors.isNotEmpty) {
      throw ValidationFailure(errors.first);
    }

    final newId = id ?? await idGen.nextReportId();
    final report = Report(
      id: newId,
      type: type.trim(),
      placeTime: placeTime.trim(),
      description: description.trim(),
      isFollowUp: isFollowUp,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
    );

    if (isOnline) {
      await repo.create(report);
    } else {
      await repo.enqueue(report);
    }
    return newId;
  }
}