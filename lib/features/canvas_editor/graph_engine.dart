import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';
import 'package:notes_playground/features/canvas_editor/domain/node_type_registry.dart';

class GraphEngine {
  GraphEngine({required this.registry});

  final NodeTypeRegistry registry;

  final Map<String, dynamic> _cache = {};

  Map<String, dynamic> computeOutputs(
    Map<String, NodeData<dynamic>> nodes,
    List<ConnectionData> connections,
  ) {
    final cache = _cache;
    final stack = <String>{};

    T? solve<T>(String nodeId) {
      if (cache.containsKey(nodeId)) return cache[nodeId] as T?;
      if (stack.contains(nodeId)) {
        throw Exception('Unsupported cycle detected at node $nodeId');
      }

      final node = nodes[nodeId];
      if (node == null) return null;

      stack.add(nodeId);
      final incoming = connections.where((c) => c.toNodeId == nodeId).toList()
        ..sort((a, b) => a.toSlot.compareTo(b.toSlot));

      final inputValues = incoming.map((c) => solve<T>(c.fromNodeId)).toList();

      final output = registry
          .byId(node.typeId)
          .computeOutput(node, inputValues);

      cache[nodeId] = output;
      stack.remove(nodeId);

      return output as T;
    }

    for (final node in nodes.values) {
      solve<dynamic>(node.id);
    }

    return Map.unmodifiable(cache);
  }

  void invalidateFrom(String nodeId, List<ConnectionData> connections) {
    final toRemove = <String>{};
    final queue = <String>[nodeId];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (!toRemove.add(current)) continue;
      for (final connection in connections) {
        if (connection.fromNodeId == current) queue.add(connection.toNodeId);
      }
    }

    toRemove.forEach(_cache.remove);
  }

  void clear() => _cache.clear();
}
