import '../../data/repositories/meeting_point_repository.dart';
import '../models/meeting_point_model.dart';

class MeetingPointRepositoryImpl implements MeetingPointRepository {
  static const List<MeetingPoint> _points = <MeetingPoint>[
    MeetingPoint(
      id: '1',
      name: 'Cancha de Fútbol - Centro Deportivo',
      lat: 4.600617,
      lng: -74.062859,
    ),
    MeetingPoint(
      id: '2',
      name: 'Paso Paseo Bolívar',
      lat: 4.600868,
      lng: -74.064304
      ,
    ),
    MeetingPoint(
      id: '3',
      name: 'Plazoleta Richard',
      lat: 4.601680,
      lng: -74.064135,
    ),
    MeetingPoint(
      id: '4',
      name: 'El Bobo',
      lat: 4.601180,
      lng: -74.065723,
    ),
    MeetingPoint(
      id: '5',
      name: 'Monumento La Pola',
      lat: 4.601640,
      lng: -74.067672,
    ),
    MeetingPoint(
      id: '6',
      name: 'Iglesia de Las Aguas',
      lat: 4.602290,
      lng: -74.067165,
    ),
    MeetingPoint(
      id: '7',
      name: 'Parque Espinosa - Alto',
      lat: 4.603039,
      lng: -74.065468,
    ),
    MeetingPoint(
      id: '8',
      name: 'Parque Espinosa - Bajo',
      lat: 4.603053,
      lng: -74.066048,
    ),
  ];

  @override
  List<MeetingPoint> getMeetingPoints() => _points;
}
