// presentation/views/protocols_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/protocol_model.dart';
import '../../features/pdf_viewer.dart';
import '../components/app_bottom_nav.dart';
import '../components/connectivity_status_icon.dart';
import '../viewmodels/protocols_viewmodel.dart';
import 'rag_screen.dart';

class ProtocolsScreen extends StatefulWidget {
  const ProtocolsScreen({super.key});

  @override
  State<ProtocolsScreen> createState() => _ProtocolsScreenState();
}

class _ProtocolsScreenState extends State<ProtocolsScreen> {
  late ProtocolsViewModel vm;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    vm = Provider.of<ProtocolsViewModel>(context, listen: false);
    vm.init();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProtocolsViewModel>(
      builder: (BuildContext context, ProtocolsViewModel vm, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Protocols & Manuals',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: Navigator.canPop(context),
            backgroundColor: Colors.white,
            elevation: 0.5,
            actions: const <Widget>[
              ConnectivityStatusIcon(),
            ],
          ),
          bottomNavigationBar: const AppBottomNav(current: 2),
          body: Stack(
            children: [
              SafeArea(
                minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _searchController,
                      onChanged: vm.onSearchChanged,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search protocols...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : vm.filtered.isEmpty
                          ? const Center(child: Text('No protocols found.'))
                          : ListView.separated(
                        itemCount: vm.filtered.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int i) {
                          final ProtocolModel p = vm.filtered[i];
                          return _ProtocolTile(protocol: p, vm: vm);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // FAB positioned at bottom right
              Positioned(
                bottom: 16,
                right: 16,
                child: _MedicalAssistantFAB(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RagScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProtocolTile extends StatelessWidget {
  const _ProtocolTile({required this.protocol, required this.vm});
  final ProtocolsViewModel vm;
  final protocol;

  @override
  Widget build(BuildContext context) {
    final name = protocol.name;
    final url = protocol.url;
    final version = protocol.version;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: const CircleAvatar(
          backgroundColor: Colors.white,
          radius: 24,
          child: Icon(
            Icons.picture_as_pdf,
            color: Colors.redAccent,
            size: 26,
          ),
        ),
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.5,
                ),
              ),
            ),
            FutureBuilder<bool>(
              future: vm.checkIsNew(name, version),
              builder: (BuildContext context, AsyncSnapshot<bool> snap) {
                final bool isNew = snap.data ?? false;
                if (!isNew) return const SizedBox.shrink();
                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          if (url.isNotEmpty) {
            await vm.markAsRead(name, version);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfViewer(pdfUrl: url, title: name),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No PDF URL found.')),
            );
          }
        },
      ),
    );
  }
}

class _MedicalAssistantFAB extends StatelessWidget {
  const _MedicalAssistantFAB({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.primary,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ask AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'About protocols',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}