import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum IncidentStatus { submitted, inProgress, resolved }

String statusLabel(IncidentStatus status) {
  switch (status) {
    case IncidentStatus.submitted:
      return 'Submitted';
    case IncidentStatus.inProgress:
      return 'In progress';
    case IncidentStatus.resolved:
      return 'Resolved';
  }
}

Color statusColor(IncidentStatus status) {
  switch (status) {
    case IncidentStatus.submitted:
      return const Color(0xFF1557A6);
    case IncidentStatus.inProgress:
      return const Color(0xFF9A6700);
    case IncidentStatus.resolved:
      return const Color(0xFF2E7D32);
  }
}

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.reportedBy,
    required this.reportedAt,
    required this.status,
    this.photoUrl,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String reportedBy;
  final DateTime reportedAt;
  final IncidentStatus status;
  final String? photoUrl;
  final DateTime? updatedAt;

  factory Incident.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Incident document ${doc.id} has no data.');
    }

    return Incident(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      location: data['location'] as String? ?? '',
      reportedBy: data['reportedBy'] as String? ?? '',
      reportedAt: _dateFrom(data['reportedAt']),
      status: IncidentStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => IncidentStatus.submitted,
      ),
      photoUrl: data['photoUrl'] as String?,
      updatedAt: _optionalDateFrom(data['updatedAt']),
    );
  }

  static DateTime _dateFrom(Object? value) {
    return _optionalDateFrom(value) ?? DateTime.now();
  }

  static DateTime? _optionalDateFrom(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
