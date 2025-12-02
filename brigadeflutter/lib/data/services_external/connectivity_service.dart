import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Future<bool> isOnline();
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _conn = Connectivity();

  @override
  Future<bool> isOnline() async {
    final List<ConnectivityResult> result = await _conn.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
