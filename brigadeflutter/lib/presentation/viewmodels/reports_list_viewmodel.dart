import 'package:flutter/foundation.dart';

import '../../data/entities/report.dart';
import '../../domain/use_cases/get_current_user.dart';
import '../../domain/use_cases/get_user_reports.dart';

class ReportsListViewModel extends ChangeNotifier {
  ReportsListViewModel({
    required this.getUserReports,
    required this.getCurrentUser,
  });
  
  final GetUserReports getUserReports;
  final GetCurrentUser getCurrentUser;
  
  List<Report> _allReports = <Report>[];
  List<Report> _filteredReports = <Report>[];
  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  
  List<Report> get reports => _filteredReports;
  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  
  Future<void> loadReports() async {
    final String? userId = getCurrentUser()?.uid;
    if (userId == null || userId.isEmpty) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }
    
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      _allReports = await getUserReports(userId);
      _filteredReports = List<Report>.from(_allReports);
      _error = null;
    } catch (e) {
      final String errorMsg = e.toString();
      if (errorMsg.contains('failed-precondition') || errorMsg.contains('index')) {
        _error = 'Database index required. Please create the Firestore composite index for reports collection (userId + timestamp). Check Firebase Console.';
      } else {
        _error = 'Failed to load reports: $e';
      }
      _allReports = <Report>[];
      _filteredReports = <Report>[];
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
