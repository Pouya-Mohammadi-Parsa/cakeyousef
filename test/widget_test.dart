import 'package:flutter_test/flutter_test.dart';

import 'package:cakeyousef/main.dart';

void main() {
  testWidgets('App boots splash branding', (tester) async {
    await tester.pumpWidget(const CakeAcademyApp());
    await tester.pump();
    expect(find.textContaining('کیک'), findsWidgets);
  });
}
