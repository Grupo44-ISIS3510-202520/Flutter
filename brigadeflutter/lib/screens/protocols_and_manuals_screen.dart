import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/pdf_viewer.dart';
import '../components/app_bottom_nav.dart';

class ProtocolsAndManualsScreen extends StatefulWidget {
  const ProtocolsAndManualsScreen({super.key});

  @override
  State<ProtocolsAndManualsScreen> createState() =>
      _ProtocolsAndManualsScreenState();
}

class _ProtocolsAndManualsScreenState extends State<ProtocolsAndManualsScreen> {
  late SharedPreferences prefs;
  bool isLoadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() => isLoadingPrefs = false);
  }

  Future<void> _markAsRead(String name, String version) async {
    await prefs.setString('last_seen_$name', version);
  }

  bool _isNew(String name, String version) {
    final seenVersion = prefs.getString('last_seen_$name');
    return seenVersion == null || seenVersion != version;
  }

  IconData _getIconForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('fire')) return Icons.local_fire_department;
    if (n.contains('earthquake')) return Icons.warning;
    if (n.contains('flood')) return Icons.water_drop;
    if (n.contains('medical')) return Icons.favorite;
    return Icons.picture_as_pdf;
  }

  Color _getColorForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('fire')) return Colors.red;
    if (n.contains('earthquake')) return Colors.orange;
    if (n.contains('flood')) return Colors.blue;
    if (n.contains('medical')) return Colors.pink;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingPrefs) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final protocolsStream = FirebaseFirestore.instance
        .collection('protocols-and-manuals')
        .orderBy('lastUpdate', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Protocols & Manuals"),
        centerTitle: true,
      ),
      bottomNavigationBar: const AppBottomNav(current: 2),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search protocols...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: protocolsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No protocols found."));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final name = (data['name'] ?? 'Unnamed').toString();
                      final url = (data['url'] ?? '').toString();
                      final version = (data['version'] ?? '').toString();
                      final icon = _getIconForName(name);
                      final color = _getColorForName(name);
                      final isNew = _isNew(name, version);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.1),
                            radius: 24,
                            child: Icon(icon, color: color, size: 26),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.5,
                                  ),
                                ),
                              ),
                              if (isNew)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade700,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "NEW",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            if (url.isNotEmpty) {
                              await _markAsRead(name, version);
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PdfViewer(
                                      pdfUrl: url,
                                      title: name,
                                    ),
                                  ),
                                ).then((_) {
                                  setState(() {}); // refresca el badge
                                });
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No PDF URL found."),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
