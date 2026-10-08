import 'package:flutter_test/flutter_test.dart';

import 'package:cakeyousef/main.dart';

void main() {
  testWidgets('App loads home screen', (tester) async {
    await tester.pumpWidget(const CakeAcademyApp());
    await tester.pump();
    expect(find.text('کیک‌اکادمی'), findsOneWidget);
  });
}
