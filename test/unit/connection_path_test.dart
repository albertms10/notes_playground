import 'package:flutter_test/flutter_test.dart';
import 'package:notes_playground/features/canvas_editor/utils/connection_path.dart';

void main() {
  test('pointNearPath detects near and far points', () {
    final path = buildPath(Offset.zero, const Offset(100, 0));

    // near the middle line
    expect(pointNearPath(path, const Offset(50, 1), tolerance: 10), isTrue);

    // far away
    expect(pointNearPath(path, const Offset(50, 50), tolerance: 10), isFalse);
  });
}
