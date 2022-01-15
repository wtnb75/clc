import 'package:flutter_test/flutter_test.dart';

import 'package:clc/main.dart';

void main() {
  testWidgets('1+1/2=3/2', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('1'), findsOneWidget);
    expect(find.text('a'), findsNothing);

    await tester.tap(find.text('1'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('÷'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text("3/2"), findsOneWidget);
  });
}
