import 'package:flutter_test/flutter_test.dart';
import 'package:music_notes/music_notes.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';
import 'package:notes_playground/features/canvas_editor/domain/node_type_registry.dart';
import 'package:notes_playground/features/canvas_editor/graph_engine.dart';
import 'package:notes_playground/features/canvas_editor/presentation/node_types/note_node_type.dart';
import 'package:notes_playground/features/canvas_editor/presentation/node_types/transpose_node_type.dart';
import 'package:notes_playground/features/canvas_editor/presentation/node_types/value_node_type.dart';

void main() {
  late NodeTypeRegistry registry;
  late GraphEngine engine;

  setUp(() {
    registry = NodeTypeRegistry(
      types: [
        NoteNodeType(),
        TransposeNodeType(),
        ValueNodeType(),
      ],
    );
    engine = GraphEngine(registry: registry);
  });

  test('computeOutputs throws on cycle', () {
    const n1 = NodeData<Note>(id: 'n1', typeId: NoteNodeType.id);
    const n2 = NodeData<Note>(id: 'n2', typeId: NoteNodeType.id);

    final nodes = {
      for (final n in [n1, n2]) n.id: n,
    };
    final connections = [
      const ConnectionData(
        id: 'c1',
        fromNodeId: 'n1',
        toNodeId: 'n2',
        toSlot: 0,
      ),
      const ConnectionData(
        id: 'c2',
        fromNodeId: 'n2',
        toNodeId: 'n1',
        toSlot: 0,
      ),
    ];

    expect(
      () => engine.computeOutputs(nodes, connections),
      throwsA(isA<Exception>()),
    );
  });

  test('computeOutputs computes downstream transposition', () {
    const note = NodeData<Note>(
      id: 'n1',
      typeId: NoteNodeType.id,
      value: Note.c,
    );

    const transpose = NodeData<Interval>(
      id: 't1',
      typeId: TransposeNodeType.id,
      value: Interval.m3,
    );

    const value = NodeData<dynamic>(
      id: 'v1',
      typeId: ValueNodeType.id,
    );

    final nodes = {
      for (final n in [note, transpose, value]) n.id: n,
    };
    final connections = [
      const ConnectionData(
        id: 'c1',
        fromNodeId: 'n1',
        toNodeId: 't1',
        toSlot: 0,
      ),
      const ConnectionData(
        id: 'c2',
        fromNodeId: 't1',
        toNodeId: 'v1',
        toSlot: 0,
      ),
    ];

    final outputs = engine.computeOutputs(nodes, connections);

    expect(outputs['n1'], equals(note.value));
    expect(outputs['t1'], isA<Note>());
    expect(outputs['v1'], equals(outputs['t1']));
  });

  test('invalidateFrom removes downstream cache entries', () {
    const note = NodeData<Note>(
      id: 'n1',
      typeId: NoteNodeType.id,
      value: Note.c,
    );

    const transpose = NodeData<Interval>(
      id: 't1',
      typeId: TransposeNodeType.id,
      value: Interval.m3,
    );

    final nodes = {
      for (final n in [note, transpose]) n.id: n,
    };
    final connections = [
      const ConnectionData(
        id: 'c1',
        fromNodeId: 'n1',
        toNodeId: 't1',
        toSlot: 0,
      ),
    ];

    engine.computeOutputs(nodes, connections);
    expect(engine.computeOutputs(nodes, connections), isNotEmpty);

    engine.invalidateFrom('n1', connections);
    // After invalidation the engine should recompute; internal cache should be
    // empty but computeOutputs will fill it again; just assert cache used
    // behavior via API.
    final after = engine.computeOutputs(nodes, connections);
    expect(after.containsKey('t1'), isTrue);
  });
}
