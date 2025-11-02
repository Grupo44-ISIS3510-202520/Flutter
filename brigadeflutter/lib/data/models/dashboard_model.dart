import 'package:flutter/material.dart';

class DashboardModel {

  const DashboardModel ({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;
}
