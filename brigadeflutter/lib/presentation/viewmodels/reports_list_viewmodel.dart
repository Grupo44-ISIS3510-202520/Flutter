import 'package:flutter/foundation.dart';

import '../../data/entities/report.dart';
import '../../domain/use_cases/get_current_user.dart';
import '../../domain/use_cases/get_user_reports.dart';
import '../../domain/use_cases/get_user_reports_with_cache.dart';

// Top-level function for isolate execution
// Filters reports based on search query in separate isolate
List<Report> _filterReportsIsolate(Map<String, dynamic> params) {
  final List<Report> allReports = params['reports'] as List<Report>;
  final String searchQuery = params['query'] as String;
  
  if (searchQuery.isEmpty) {
    return List<Report>.from(allReports);
  }
  
  return allReports.where((Report report) {
    final String searchLower = searchQuery.toLowerCase();
    return report.reportId.toLowerCase().contains(searchLower) ||
           report.type.toLowerCase().contains(searchLower) ||
           report.place.toLowerCase().contains(searchLower) ||
           report.description.toLowerCase().contains(searchLower);
  }).toList();
}

class ReportsListViewModel extends ChangeNotifier {
  ReportsListViewModel({
    required this.getUserReports,
    required this.getUserReportsWithCache,
    required this.getCurrentUser,
  });
  
  final GetUserReports getUserReports;
  final GetUserReportsWithCache getUserReportsWithCache;
  final GetCurrentUser getCurrentUser;
  
  List<Report> _allReports = <Report>[];
  List<Report> _filteredReports = <Report>[];
  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  bool _fromCache = false;
  DateTime? _lastSyncTime;
  
  List<Report> get reports => _filteredReports;
  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get fromCache => _fromCache;
  DateTime? get lastSyncTime => _lastSyncTime;
  
  Future<void> loadReports() async {
    final String? userId = getCurrentUser()?.uid;
    if (userId == null || userId.isEmpty) {
      _error = 'User not authenticated';
      _fromCache = false;
      notifyListeners();
      return;
    }
    
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      // MULTITHREADING STRATEGY: Get reports and prepare data concurrently
      final result = await getUserReportsWithCache(userId);
      
      // Process results - copy list creation and cache time check can run in parallel
      if (result.fromCache) {
        // When using cache, fetch lastSyncTime in parallel with list copy
        final futures = await Future.wait<dynamic>([
          Future<List<Report>>(() => List<Report>.from(result.reports)),
          getUserReportsWithCache.getLastSyncTime(),
        ]);
        
        _allReports = result.reports;
        _filteredReports = futures[0] as List<Report>;
        _lastSyncTime = futures[1] as DateTime?;
      } else {
        // Fresh data - no need for parallel operations
        _allReports = result.reports;
        _filteredReports = List<Report>.from(_allReports);
        _lastSyncTime = DateTime.now();
      }
      
      _fromCache = result.fromCache;
      _error = null;
    } catch (e) {
      final String errorMsg = e.toString();
      if (errorMsg.contains('No internet connection and no cached reports')) {
        _error = 'No internet connection. Past reports require internet to load and cannot be displayed offline.';
      } else if (errorMsg.contains('failed-precondition') || errorMsg.contains('index')) {
        _error = 'Database index required. Please create the Firestore composite index for reports collection (userId + timestamp). Check Firebase Console.';
      } else {
        _error = 'Failed to load reports: $e';
      }
      _allReports = <Report>[];
      _filteredReports = <Report>[];
      _fromCache = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  void search(String query) async {
    _searchQuery = query.trim();
    
    // ISOLATE STRATEGY: For large datasets (>50 items), use isolate for filtering
    // This prevents UI freezing during search on large lists
    if (_allReports.length > 50) {
      // Run filtering in separate isolate to keep UI responsive
      _filteredReports = await compute(
        _filterReportsIsolate,
        <String, dynamic>{
          'reports': _allReports,
          'query': _searchQuery,
        },
      );
    } else {
      // For small lists, direct filtering is faster (no isolate overhead)
      if (_searchQuery.isEmpty) {
        _filteredReports = List<Report>.from(_allReports);
      } else {
        final String searchLower = _searchQuery.toLowerCase();
        _filteredReports = _allReports.where((Report report) {
          return report.reportId.toLowerCase().contains(searchLower) ||
                 report.type.toLowerCase().contains(searchLower) ||
                 report.place.toLowerCase().contains(searchLower) ||
                 report.description.toLowerCase().contains(searchLower);
        }).toList();
      }
    }
    
    notifyListeners();
  }
  
  void clearSearch() {
    _searchQuery = '';
    _filteredReports = List<Report>.from(_allReports);
    notifyListeners();
  }
}
