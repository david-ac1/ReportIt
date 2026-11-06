import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reportit/app.dart';

void main() {
  testWidgets('renders the ReportIt foundation screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ReportItApp()),
    );

    expect(find.text('ReportIt'), findsOneWidget);
    expect(find.text('Campus issues, heard and resolved.'), findsOneWidget);
  });
}
