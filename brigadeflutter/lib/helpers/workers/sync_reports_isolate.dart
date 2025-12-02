import 'package:flutter/foundation.dart';

import '../../data/models/report_model.dart';

/// Processes report models in an isolate to determine which need new IDs
/// Returns list of reports with updated IDs
List<ReportModel> processReportsForSync(List<ReportModel> reports) {
  final List<ReportModel> processedReports = [];
  
  for (final ReportModel model in reports) {
    // For offline reports, we'll need to generate new IDs in main thread
    // This isolate just prepares the data
    processedReports.add(model);
    
    if (kDebugMode && model.reportId.startsWith('OFFLINE_')) {
      print('ProcessIsolate: Report ${model.reportId} needs new Firestore ID');
    }
  }
  
  return processedReports;
}
