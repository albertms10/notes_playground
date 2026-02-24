import 'package:flutter_test/flutter_test.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';
import 'package:notes_playground/features/canvas_editor/utils/graph_utils.dart';

void main() {
  test('wouldCreateCycle detects cycles', () {
    final connections = [
      const ConnectionData(id: 'c1', fromNodeId: 'a', toNodeId: 'b', toSlot: 0),
      const ConnectionData(id: 'c2', fromNodeId: 'b', toNodeId: 'c', toSlot: 0),
    ];

    expect(wouldCreateCycle(connections, 'a', 'c'), isFalse);
    // adding c -> a would create cycle
    final connections2 = [
      ...connections,
      const ConnectionData(id: 'c3', fromNodeId: 'c', toNodeId: 'a', toSlot: 0),
    ];

    expect(wouldCreateCycle(connections2, 'a', 'c'), isTrue);
  });
}
