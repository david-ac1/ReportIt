import 'package:flutter_test/flutter_test.dart';

import 'package:reportit/features/auth/presentation/auth_page.dart';

void main() {
  test('accepts only ALU student email addresses', () {
    expect(isAllowedAluEmail('student@alustudent.com'), isTrue);
    expect(isAllowedAluEmail('STUDENT@ALUSTUDENT.COM'), isTrue);
    expect(isAllowedAluEmail('student@gmail.com'), isFalse);
    expect(isAllowedAluEmail('student@alustudent.com.example'), isFalse);
  });
}
