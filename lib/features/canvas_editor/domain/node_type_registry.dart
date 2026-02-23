import 'package:flutter/foundation.dart' show immutable;
import 'package:notes_playground/features/canvas_editor/domain/node_type_definition.dart';

@immutable
class NodeTypeRegistry {
  NodeTypeRegistry({
    required List<NodeTypeDefinition<dynamic, dynamic>> types,
  }) : _types = types,
       _byId = {for (final type in types) type.typeId: type};

  final List<NodeTypeDefinition<dynamic, dynamic>> _types;
  final Map<String, NodeTypeDefinition<dynamic, dynamic>> _byId;

  List<NodeTypeDefinition<dynamic, dynamic>> get types =>
      List.unmodifiable(_types);

  NodeTypeDefinition<dynamic, dynamic> byId(String typeId) {
    return _byId[typeId] ?? _types.first;
  }

  NodeTypeDefinition<dynamic, dynamic> cycle(int index) {
    return _types[index % _types.length];
  }
}
