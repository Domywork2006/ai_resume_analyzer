import 'package:flutter_test/flutter_test.dart';
import 'package:ai_resume_analyzer/main.dart';

void main() {
  testWidgets('ResumeAnalyzerApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ResumeAnalyzerApp());
    await tester.pumpAndSettle();
  });
}
