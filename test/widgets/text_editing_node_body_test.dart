import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_playground/features/canvas_editor/presentation/widgets/text_editing_node_body.dart';

void main() {
  testWidgets('shows red border for invalid input and blue for valid', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextEditingNodeBody(
            controller: TextEditingController(text: 'A'),
            displayText: (s) => s,
            validateText: (s) => s == 'OK',
          ),
        ),
      ),
    );

    // Tap to enter edit mode
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    // Enter invalid text
    await tester.enterText(find.byType(TextField), 'bad');
    await tester.pumpAndSettle();

    final invalidDecoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration!;
    // expecting invalid border color red-ish
    expect(
      invalidDecoration.enabledBorder!.borderSide.color,
      isNot(equals(Colors.blue.shade300)),
    );

    // Enter valid text
    await tester.enterText(find.byType(TextField), 'OK');
    await tester.pumpAndSettle();

    final validDecoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration!;
    expect(
      validDecoration.enabledBorder!.borderSide.color,
      equals(Colors.blue.shade300),
    );
  });
}
