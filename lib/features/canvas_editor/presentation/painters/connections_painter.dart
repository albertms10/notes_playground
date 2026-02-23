import 'package:flutter/material.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';

typedef OutputPositionResolver = Offset Function(String nodeId);
typedef InputPositionResolver = Offset Function(String nodeId, int slot);
typedef PathBuilder = Path Function(Offset from, Offset to);

@immutable
class ConnectionsPainter extends CustomPainter {
  const ConnectionsPainter({
    required this.nodes,
    required this.connections,
    required this.selectedConnectionId,
    required this.draftConnection,
    required this.outputPositionOf,
    required this.inputPositionOf,
    required this.buildPath,
    required this.hoveredInput,
    required this.validDrop,
  });

  final Map<String, NodeData<dynamic>> nodes;
  final List<ConnectionData> connections;
  final String? selectedConnectionId;
  final DraftConnection? draftConnection;
  final OutputPositionResolver outputPositionOf;
  final InputPositionResolver inputPositionOf;
  final PathBuilder buildPath;
  final InputHit? hoveredInput;
  final bool validDrop;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..style = .stroke
      ..strokeCap = .round
      ..strokeWidth = 2.4
      ..color = const Color(0xFF5E7D78).withValues(alpha: 0.52);

    final selectedPaint = Paint()
      ..style = .stroke
      ..strokeCap = .round
      ..strokeWidth = 3.6
      ..color = const Color(0xFF1F4F46);

    for (final connection in connections) {
      if (!nodes.containsKey(connection.fromNodeId) ||
          !nodes.containsKey(connection.toNodeId) ||
          draftConnection?.reconnectingConnectionId == connection.id) {
        continue;
      }

      final path = buildPath(
        outputPositionOf(connection.fromNodeId),
        inputPositionOf(connection.toNodeId, connection.toSlot),
      );
      canvas.drawPath(
        path,
        connection.id == selectedConnectionId ? selectedPaint : basePaint,
      );
    }

    final draft = draftConnection;
    if (draft != null && nodes.containsKey(draft.fromNodeId)) {
      final target = hoveredInput != null && validDrop
          ? inputPositionOf(hoveredInput!.nodeId, hoveredInput!.slot)
          : draft.cursorWorld;

      final path = buildPath(outputPositionOf(draft.fromNodeId), target);
      final draftPaint = Paint()
        ..style = .stroke
        ..strokeCap = .round
        ..strokeWidth = 3
        ..color = validDrop
            ? const Color(0xFF2E7468)
            : const Color(0xFF7A8F8B).withValues(alpha: 0.7);
      canvas.drawPath(path, draftPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionsPainter oldDelegate) {
    return true;
  }
}
