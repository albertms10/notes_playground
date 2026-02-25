import 'package:flutter/material.dart';
import 'package:music_notes/music_notes.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';

@immutable
abstract class NodeTypeDefinition<V, O> {
  String get typeId;
  String get title;
  Color get borderColor;
  V? get defaultValue;
  bool get acceptsInputConnections;

  int inputSlots(String nodeId, List<ConnectionData> connections);

  double get nodeHeight => 156;

  O? output(NodeData<V> node, List<dynamic> inputValues);

  Widget builder({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    O? output,
  });

  /// Returns the [StringParser] for a given [text], or null if not available.
  StringParser<V>? parser(String text);
}
