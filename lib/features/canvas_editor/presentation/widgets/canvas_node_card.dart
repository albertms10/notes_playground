import 'package:flutter/material.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';
import 'package:notes_playground/features/canvas_editor/domain/node_type_definition.dart';
import 'package:notes_playground/features/canvas_editor/presentation/widgets/connector_dot.dart';

@immutable
class CanvasNodeCard<V, O> extends StatelessWidget {
  const CanvasNodeCard({
    required this.node,
    required this.nodeType,
    required this.height,
    required this.width,
    required this.editor,
    required this.inputSlots,
    required this.inputTopOf,
    required this.outputTop,
    required this.draft,
    required this.hoveredInput,
    required this.isInputValid,
    required this.onNodePanStart,
    required this.onNodePanUpdate,
    required this.onNodePanEnd,
    required this.onOutputPanStart,
    required this.onOutputPanUpdate,
    required this.onOutputPanEnd,
    super.key,
  });

  final NodeData<V> node;
  final NodeTypeDefinition<V, O> nodeType;
  final double height;
  final double width;
  final Widget editor;
  final int inputSlots;
  final double Function(int slot) inputTopOf;
  final double outputTop;
  final DraftConnection? draft;
  final InputHit? hoveredInput;
  final bool Function(int slot) isInputValid;
  final GestureDragStartCallback onNodePanStart;
  final GestureDragUpdateCallback onNodePanUpdate;
  final GestureDragEndCallback onNodePanEnd;
  final GestureDragStartCallback onOutputPanStart;
  final GestureDragUpdateCallback onOutputPanUpdate;
  final GestureDragEndCallback onOutputPanEnd;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: .none,
          children: [
            GestureDetector(
              onPanStart: onNodePanStart,
              onPanUpdate: onNodePanUpdate,
              onPanEnd: onNodePanEnd,
              child: Container(
                padding: const .symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: .circular(14),
                  border: .all(
                    color: nodeType.borderColor.withValues(alpha: 0.75),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      nodeType.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: .w600,
                        color: nodeType.borderColor.withValues(alpha: 0.9),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    editor,
                  ],
                ),
              ),
            ),
            ...List.generate(inputSlots, (slot) {
              final isHovered =
                  hoveredInput?.nodeId == node.id &&
                  hoveredInput?.slot == slot &&
                  draft != null;

              return Positioned(
                left: -8,
                top: inputTopOf(slot),
                child: ConnectorDot(
                  highlighted: isHovered,
                  accept: isInputValid(slot),
                ),
              );
            }),
            Positioned(
              right: -8,
              top: outputTop,
              child: GestureDetector(
                behavior: .opaque,
                onPanStart: onOutputPanStart,
                onPanUpdate: onOutputPanUpdate,
                onPanEnd: onOutputPanEnd,
                child: const ConnectorDot(output: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
