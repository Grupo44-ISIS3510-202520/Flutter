import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsService {
  static final AnalyticsService I = AnalyticsService._();
  AnalyticsService._();

  final FirebaseAnalytics _ga = FirebaseAnalytics.instance;

  Future<void> setUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) await _ga.setUserId(id: uid);
  }

  Future<void> logView(String screen) =>
      _ga.logScreenView(screenName: screen);

  Future<void> logGpsUsed() =>
      _ga.logEvent(name: 'gps_used_for_report');


  Map<String, Object> _sanitize(Map<String, dynamic> params) {
    final out = <String, Object>{};
    params.forEach((k, v) {
      if (v == null) return;
      if (v is bool) {
        out[k] = v ? 1 : 0;  
      } else if (v is num || v is String) {
        out[k] = v;
      } else {
        out[k] = v.toString();
      }
    });
    return out;
  }

  Future<void> logReportPlaceFilled({
    required String method,
    required int ms,
  }) async {
    await _ga.logEvent(
      name: 'report_place_filled',
      parameters: _sanitize({
        'method': method,
        'ms': ms,
      }),
    );
  }

  Future<void> logReportSubmitted({
    required String type,
    required bool followUp,
    required bool usedGps,
    int? msTotal,
  }) async {
    final params = {
      'type': type,
      'follow_up': followUp, 
      'used_gps': usedGps,
      if (msTotal != null) 'ms_total': msTotal,
    };
    await _ga.logEvent(
      name: 'report_submitted',
      parameters: _sanitize(params),
    );
  }
}
