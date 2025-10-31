import '../models/meeting_point_model.dart';

abstract class MeetingPointRepository {
  List<MeetingPoint> getMeetingPoints();
}
