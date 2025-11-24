import '../../helpers/errors/failures.dart';
import '../../helpers/utils/id_generator.dart';
import '../../helpers/utils/validators.dart';
import '../../data/entities/report.dart';
import '../../data/repositories/report_repository.dart';

class CreateEmergencyReport {
  CreateEmergencyReport(this.repo, this.idGen);
  final ReportRepository repo;
  final FirestoreIdGenerator idGen;

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
    final Iterable<String> errors = <String?>[
      validateType(type),
      validatePlaceTime(placeTime),
      validateDescription(description),
    ].whereType<String>();
    if (errors.isNotEmpty) {
      throw ValidationFailure(errors.first);
    }

    final int newId =
        id ??
        (isOnline
            ? await idGen.nextReportId()
            : DateTime.now().millisecondsSinceEpoch);
    final Report report = Report(
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
