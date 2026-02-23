import 'package:flutter/material.dart' hide Interval;
import 'package:music_notes/music_notes.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';
import 'package:notes_playground/features/canvas_editor/domain/node_type_definition.dart';
import 'package:notes_playground/features/canvas_editor/presentation/widgets/text_editing_node_body.dart';

@immutable
class TransposeNodeType extends NodeTypeDefinition<Interval, Note> {
  static const String id = 'transpose';

  @override
  String get typeId => id;

  @override
  String get title => 'Transpose';

  @override
  Color get borderColor => const Color(0xFF7C8DA9);

  @override
  Interval get defaultValue => .m2;

  @override
  bool get acceptsInputConnections => true;

  @override
  int inputSlots(String nodeId, List<ConnectionData> connections) => 1;

  @override
  double nodeHeight(String nodeId, List<ConnectionData> connections) => 156;

  @override
  Note? computeOutput(NodeData<Interval> node, List<dynamic> inputValues) =>
      node.value != null
      ? (inputValues.singleOrNull as Note?)?.transposeBy(node.value!)
      : null;

  @override
  Widget buildEditor({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    Note? output,
  }) => TextEditingNodeBody(
    controller: controller,
    onChanged: onChanged,
    validateText: (value) => Interval.parsers.match(value),
    displayText: (text) => Interval.parse(text).toString(),
  );

  @override
  Interval? parseValue(String text) => Interval.parse(text);
}
