import 'package:flutter/material.dart' hide Interval;
import 'package:music_notes/music_notes.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';
import 'package:notes_playground/features/canvas_editor/domain/node_type_definition.dart';
import 'package:notes_playground/features/canvas_editor/presentation/widgets/text_node_body.dart';

@immutable
class ValueNodeType<V, O> extends NodeTypeDefinition<V, O> {
  static const String id = 'value';

  @override
  String get typeId => id;

  @override
  String get title => 'Value';

  @override
  Color get borderColor => const Color(0xFF7C8DA9);

  @override
  V? get defaultValue => null;

  @override
  bool get acceptsInputConnections => true;

  @override
  int inputSlots(String nodeId, List<ConnectionData> connections) => 1;

  @override
  O? output(NodeData<V> node, List<dynamic> inputValues) =>
      inputValues.singleOrNull as O?;

  @override
  Widget builder({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    O? output,
  }) => TextNodeBody(
    value: output,
    displayText: (text) => switch (output) {
      Interval() => Interval.parse(text).toString(),
      Note() => Note.parse(text).toString(),
      _ => text,
    },
  );

  @override
  V parseValue(String text) => throw UnimplementedError(
    'Parsing not implemented for generic ValueNodeType.',
  );
}
