import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../reports/application/incident_providers.dart';
import '../../reports/data/incident.dart';

class StaffHomePage extends ConsumerWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidents = ref.watch(allIncidentsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff reports'),
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
            child: Text('Unable to load staff reports: $error'),
          ),
        ),
        data: (reports) => reports.isEmpty
            ? const Center(child: Text('No incident reports yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _StaffIncidentCard(incident: reports[index]),
              ),
      ),
    );
  }
}

class _StaffIncidentCard extends ConsumerWidget {
  const _StaffIncidentCard({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(incident.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('${incident.category} • ${incident.location}'),
            const SizedBox(height: 12),
            Text(incident.description),
            const SizedBox(height: 12),
            DropdownButtonFormField<IncidentStatus>(
              initialValue: incident.status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: IncidentStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(statusLabel(status)),
                    ),
                  )
                  .toList(),
              onChanged: (status) async {
                if (status == null || status == incident.status) return;
                try {
                  await ref
                      .read(incidentRepositoryProvider)
                      .updateStatus(incidentId: incident.id, status: status);
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not update status: $error')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
