import 'package:flutter/foundation.dart';

import '../../data/entities/report.dart';
import '../../domain/use_cases/get_current_user.dart';
import '../../domain/use_cases/get_user_reports.dart';
import '../../domain/use_cases/get_user_reports_with_cache.dart';

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
      final result = await getUserReportsWithCache(userId);
      _allReports = result.reports;
      _filteredReports = List<Report>.from(_allReports);
      _fromCache = result.fromCache;
      _error = null;
      
      if (_fromCache) {
        _lastSyncTime = await getUserReportsWithCache.getLastSyncTime();
      } else {
        _lastSyncTime = DateTime.now();
      }
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
  
  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    
    if (_searchQuery.isEmpty) {
      _filteredReports = List<Report>.from(_allReports);
    } else {
      _filteredReports = _allReports.where((Report report) {
        return report.type.toLowerCase().contains(_searchQuery) ||
               report.description.toLowerCase().contains(_searchQuery) ||
               report.place.toLowerCase().contains(_searchQuery) ||
               report.reportId.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    
    notifyListeners();
  }
  
  void clearSearch() {
    _searchQuery = '';
    _filteredReports = List<Report>.from(_allReports);
    notifyListeners();
  }
}
