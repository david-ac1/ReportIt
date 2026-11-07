import 'package:flutter/material.dart';

import '../data/incident.dart';

class IncidentDetailsPage extends StatelessWidget {
  const IncidentDetailsPage({required this.incident, super.key});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            incident.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Status', value: statusLabel(incident.status)),
          _DetailRow(label: 'Category', value: incident.category),
          _DetailRow(label: 'Location', value: incident.location),
          const Divider(height: 32),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(incident.description),
          const SizedBox(height: 24),
          Text(
            'Submitted ${_formatDate(incident.reportedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day}/${localDate.month}/${localDate.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
