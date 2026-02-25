import 'package:flutter/material.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';

@immutable
abstract class NodeTypeDefinition<V, O> {
  String get typeId;
  String get title;
  Color get borderColor;
  V? get defaultValue;
  bool get acceptsInputConnections;

  int inputSlots(String nodeId, List<ConnectionData> connections);

  double nodeHeight(String nodeId, List<ConnectionData> connections);

  O? computeOutput(NodeData<V> node, List<dynamic> inputValues);

  Widget buildEditor({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    O? output,
  });

  /// Attempts to parse a value of type [V] from [text].
  ///
  /// Default implementation returns `null` which signals the caller to
  /// store the raw string if no typed parsing is available.
  V parseValue(String text);
}
