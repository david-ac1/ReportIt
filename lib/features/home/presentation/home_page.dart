import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../reports/application/incident_providers.dart';
import '../../reports/data/incident.dart';
import '../../reports/presentation/create_incident_page.dart';
import '../../reports/presentation/incident_details_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _searchQuery = '';
  String? _categoryFilter;
  IncidentStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final incidents = ref.watch(incidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReportIt'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: incidents.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load your reports: $error'),
          ),
        ),
        data: (reports) {
          if (reports.isEmpty && _searchQuery.isEmpty) {
            return _EmptyReports(onCreate: () => _openCreatePage(context));
          }
          final filteredReports = reports.where(_matchesFilters).toList();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredReports.length + 1,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _FilterBar(
                  searchQuery: _searchQuery,
                  category: _categoryFilter,
                  status: _statusFilter,
                  onSearchChanged: (value) =>
                      setState(() => _searchQuery = value),
                  onCategoryChanged: (value) =>
                      setState(() => _categoryFilter = value),
                  onStatusChanged: (value) =>
                      setState(() => _statusFilter = value),
                );
              }
              if (filteredReports.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No reports match your filters.'),
                  ),
                );
              }
              final report = filteredReports[index - 1];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.report_problem_outlined),
                  ),
                  title: Text(report.title),
                  subtitle: Text(
                    '${report.category} • ${report.location}\n'
                    '${statusLabel(report.status)}',
                  ),
                  isThreeLine: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => IncidentDetailsPage(incident: report),
                    ),
                  ),
                ),
              );
            },
          );
        },
        skipLoadingOnRefresh: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreatePage(context),
        icon: const Icon(Icons.add),
        label: const Text('New report'),
      ),
    );
  }

  bool _matchesFilters(Incident report) {
    final query = _searchQuery.trim().toLowerCase();
    final matchesSearch =
        query.isEmpty ||
        report.title.toLowerCase().contains(query) ||
        report.description.toLowerCase().contains(query) ||
        report.location.toLowerCase().contains(query);
    final matchesCategory =
        _categoryFilter == null || report.category == _categoryFilter;
    final matchesStatus =
        _statusFilter == null || report.status == _statusFilter;
    return matchesSearch && matchesCategory && matchesStatus;
  }

  Future<void> _openCreatePage(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreateIncidentPage()));
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.searchQuery,
    required this.category,
    required this.status,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onStatusChanged,
  });

  final String searchQuery;
  final String? category;
  final IncidentStatus? status;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<IncidentStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search reports',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All categories'),
                  ),
                  ...incidentCategories.map(
                    (value) => DropdownMenuItem<String?>(
                      value: value,
                      child: Text(value),
                    ),
                  ),
                ],
                onChanged: onCategoryChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<IncidentStatus?>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  const DropdownMenuItem<IncidentStatus?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  ...IncidentStatus.values.map(
                    (value) => DropdownMenuItem<IncidentStatus?>(
                      value: value,
                      child: Text(statusLabel(value)),
                    ),
                  ),
                ],
                onChanged: onStatusChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'No reports yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Help improve campus by reporting an issue when you find one.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create your first report'),
            ),
          ],
        ),
      ),
    );
  }
}
