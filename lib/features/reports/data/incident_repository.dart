import 'package:cloud_firestore/cloud_firestore.dart';

import 'incident.dart';

class IncidentRepository {
  IncidentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Incident>> watchIncidents(String userId) {
    return _watchQuery(
      _firestore
          .collection('incidents')
          .where('reportedBy', isEqualTo: userId)
          .orderBy('reportedAt', descending: true),
    );
  }

  Stream<List<Incident>> watchAllIncidents() {
    return _watchQuery(
      _firestore.collection('incidents').orderBy(
            'reportedAt',
            descending: true,
          ),
    );
  }

  Stream<List<Incident>> _watchQuery(
    Query<Map<String, dynamic>> query,
  ) {
    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map(Incident.fromDocument)
              .toList(growable: false),
        );
  }

  Future<void> createIncident({
    required String userId,
    required String title,
    required String description,
    required String category,
    required String location,
  }) async {
    final incidentReference = _firestore.collection('incidents').doc();

    await incidentReference.set({
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'reportedBy': userId,
      'reportedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': IncidentStatus.submitted.name,
    });
  }

  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus status,
  }) {
    return _firestore.collection('incidents').doc(incidentId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
