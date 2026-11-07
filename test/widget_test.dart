import 'package:flutter_test/flutter_test.dart';

import 'package:reportit/features/auth/presentation/auth_page.dart';
import 'package:reportit/features/reports/data/incident.dart';

void main() {
  test('accepts only ALU student email addresses', () {
    expect(isAllowedAluEmail('student@alustudent.com'), isTrue);
    expect(isAllowedAluEmail('STUDENT@ALUSTUDENT.COM'), isTrue);
    expect(isAllowedAluEmail('student@gmail.com'), isFalse);
    expect(isAllowedAluEmail('student@alustudent.com.example'), isFalse);
  });

  test('provides readable incident status labels', () {
    expect(statusLabel(IncidentStatus.submitted), 'Submitted');
    expect(statusLabel(IncidentStatus.inProgress), 'In progress');
    expect(statusLabel(IncidentStatus.resolved), 'Resolved');
  });
}
