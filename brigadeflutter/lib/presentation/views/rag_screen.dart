// presentation/views/rag_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/rag_model.dart';
import '../viewmodels/rag_viewmodel.dart';

class RagScreen extends StatefulWidget {
  const RagScreen({super.key});

  @override
  State<RagScreen> createState() => _RagScreenState();
}

class _RagScreenState extends State<RagScreen> {
  final TextEditingController _queryController = TextEditingController();
  late RagViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<RagViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RagViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'AI Assistant',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
          ),
          body: Container(
            color: const Color(0xFFFBF8F2),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildCacheInfoCard(vm),
                    const SizedBox(height: 16),
                    _buildQueryInput(vm),
                    const SizedBox(height: 16),
                    Expanded(child: _buildStateContent(vm)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCacheInfoCard(RagViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.library_books,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                '${vm.cacheSize} answers cached',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.history,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onPressed: () {
              vm.loadCacheHistory();
              _showHistoryDialog(vm);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQueryInput(RagViewModel vm) {
    final isLoading = vm.state is RagLoading;

    return TextField(
      controller: _queryController,
      decoration: InputDecoration(
        hintText: 'Ask about protocols...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send),
          onPressed: isLoading || _queryController.text.trim().isEmpty
              ? null
              : () {
            vm.askQuestion(_queryController.text);
          },
        ),
      ),
      enabled: !isLoading,
      onSubmitted: isLoading
          ? null
          : (value) {
        if (value.trim().isNotEmpty) {
          vm.askQuestion(value);
        }
      },
    );
  }

  Widget _buildStateContent(RagViewModel vm) {
    final state = vm.state;

    if (state is RagIdle) {
      return _buildEmptyState();
    } else if (state is RagLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is RagSuccess) {
      return _buildAnswerCard(state);
    } else if (state is RagError) {
      return _buildErrorCard(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medical_services,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ask me anything about the protocols',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'I can help you with information about the BEU protocols',
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerCard(RagSuccess state) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.fromCache)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  'From cache',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            if (state.fromCache) const SizedBox(height: 16),
            const Text(
              'Answer:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.answer,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sources:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...state.sources.map((source) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.library_books,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      source,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(RagError state) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDialog(RagViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cached Answers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: vm.cacheHistory.isEmpty
                    ? const Center(
                  child: Text('No cached answers yet'),
                )
                    : ListView.separated(
                  itemCount: vm.cacheHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = vm.cacheHistory[index];
                    return _buildHistoryItem(entry, vm);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(RagCacheEntry entry, RagViewModel vm) {
    return InkWell(
      onTap: () {
        _queryController.text = entry.query;
        vm.useCachedQuery(entry);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.query,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              entry.answer,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.library_books,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.sources.length} source(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatTimestamp(entry.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM dd, HH:mm').format(date);
    }
  }
}