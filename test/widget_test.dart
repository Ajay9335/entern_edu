import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:entern_edu/main.dart';

void main() {
  testWidgets('app shows splash screen content', (WidgetTester tester) async {
    await tester.pumpWidget(const InternEduApp());

    expect(find.text('Intern Edu'), findsOneWidget);
    expect(find.text('Learn. Intern. Grow.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
