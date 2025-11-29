import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../data/entities/report.dart';
import '../components/app_bar_actions.dart';
import '../components/app_bottom_nav.dart';
import '../components/connectivity_status_icon.dart';
import '../viewmodels/reports_list_viewmodel.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsListViewModel>().loadReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Widget _buildCacheBanner(ReportsListViewModel vm) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final String lastSync = vm.lastSyncTime != null
        ? dateFormat.format(vm.lastSyncTime!)
        : 'Unknown';
    
    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Icon(Icons.cloud_off, size: 20, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Viewing cached reports',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Last synced: $lastSync',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsListViewModel>(
      builder: (_, ReportsListViewModel vm, __) {
        return Scaffold(
          appBar: AppBar(
            leading: backToDashboardButton(context),
            title: const Text(
              'Emergency Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            actions: <Widget>[
              const ConnectivityStatusIcon(),
              signOutAction(context),
            ],
          ),
          bottomNavigationBar: const AppBottomNav(current: 0),
          body: Column(
            children: <Widget>[
              // Offline banner
              if (vm.fromCache) _buildCacheBanner(vm),
              
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: vm.search,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              vm.clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: _buildContent(vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ReportsListViewModel vm) {
    if (vm.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              vm.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.loadReports(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vm.reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              vm.searchQuery.isEmpty
                  ? 'No reports submitted yet'
                  : 'No reports found for \"${vm.searchQuery}\"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: vm.reports.length,
        itemBuilder: (BuildContext context, int index) {
          final Report report = vm.reports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
    final String formattedDate = dateFormat.format(report.timestamp);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showReportDetails(report);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      report.type,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.place,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetails(Report report) {
    final DateFormat dateFormat = DateFormat('MMMM dd, yyyy • HH:mm:ss');
    final String formattedDate = dateFormat.format(report.timestamp);
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, ScrollController scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: scrollController,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Report Details',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${report.reportId}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Type', report.type),
                  _buildDetailRow('Description', report.description),
                  _buildDetailRow('Place', report.place),
                  _buildDetailRow('Date & Time', formattedDate),
                  if (report.latitude != null && report.longitude != null)
                    _buildDetailRow(
                      'Coordinates',
                      '${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}',
                    ),
                  _buildDetailRow(
                    'Elapsed Time',
                    '${report.elapsedTime} ${report.elapsedTime == 1 ? 'second' : 'seconds'}',
                  ),
                  _buildDetailRow(
                    'Follow-up Report',
                    report.isFollowUp ? 'Yes' : 'No',
                  ),
                  if (report.audioUrl != null)
                    _buildDetailRow('Audio', report.audioUrl!),
                  if (report.imageUrl != null)
                    _buildDetailRow('Image', report.imageUrl!),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
