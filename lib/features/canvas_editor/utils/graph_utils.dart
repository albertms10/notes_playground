import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';

/// Determines whether connecting from [fromNodeId] to [toNodeId] would
/// create a cycle given the existing [connections].
bool wouldCreateCycle(
  List<ConnectionData> connections,
  String fromNodeId,
  String toNodeId,
) {
  final next = <String, List<String>>{};
  for (final connection in connections) {
    next.putIfAbsent(connection.fromNodeId, () => []).add(connection.toNodeId);
  }

  final visited = <String>{};
  final stack = <String>[toNodeId];
  while (stack.isNotEmpty) {
    final nodeId = stack.removeLast();
    if (!visited.add(nodeId)) continue;
    if (nodeId == fromNodeId) return true;
    stack.addAll(next[nodeId] ?? const []);
  }

  return false;
}
