import 'package:flutter/material.dart';
import 'package:music_notes/music_notes.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';
import 'package:notes_playground/features/canvas_editor/domain/node_type_definition.dart';
import 'package:notes_playground/features/canvas_editor/presentation/widgets/text_editing_node_body.dart';

@immutable
class NoteNodeType extends NodeTypeDefinition<Note, Note> {
  static const String id = 'note';

  @override
  String get typeId => id;

  @override
  String get title => 'Note';

  @override
  Color get borderColor => const Color(0xFF7C8DA9);

  @override
  Note get defaultValue => .a;

  @override
  bool get acceptsInputConnections => false;

  @override
  int inputSlots(String nodeId, List<ConnectionData> connections) => 0;

  @override
  Note? output(NodeData<Note> node, List<dynamic> inputValues) => node.value;

  @override
  Widget builder({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    Note? output,
  }) => TextEditingNodeBody(
    controller: controller,
    onChanged: onChanged,
    validateText: (value) => Note.parsers.matches(value),
    displayText: (text) => parseValue(text).toString(),
  );

  @override
  Note parseValue(String text) => Note.parse(text);
}
