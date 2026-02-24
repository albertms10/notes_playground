import 'package:flutter_test/flutter_test.dart';
import 'package:notes_playground/features/canvas_editor/connection_manager.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';

void main() {
  test('applyConnection removes existing incoming to same slot', () {
    final manager =
        ConnectionManager([
          const ConnectionData(
            id: 'c1',
            fromNodeId: 'a',
            toNodeId: 't',
            toSlot: 0,
          ),
        ])..applyConnection(
          fromNodeId: 'b',
          target: const InputHit(nodeId: 't', slot: 0),
          idGenerator: () => 'c2',
        );

    final conns = manager.connections;
    expect(conns.length, equals(1));
    expect(conns.first.id, equals('c2'));
    expect(conns.first.fromNodeId, equals('b'));
  });

  test('applyConnection replaces reconnecting connection', () {
    final manager =
        ConnectionManager([
          const ConnectionData(
            id: 'c1',
            fromNodeId: 'a',
            toNodeId: 'x',
            toSlot: 0,
          ),
        ])..applyConnection(
          fromNodeId: 'a',
          target: const InputHit(nodeId: 't', slot: 0),
          reconnectingConnectionId: 'c1',
          idGenerator: () => 'ignored',
        );

    final conns = manager.connections;
    expect(conns.length, equals(1));
    expect(conns.first.id, equals('c1'));
    expect(conns.first.toNodeId, equals('t'));
  });

  test('allows multiple outgoing from same node', () {
    final manager =
        ConnectionManager([
          const ConnectionData(
            id: 'c1',
            fromNodeId: 'a',
            toNodeId: 'x',
            toSlot: 0,
          ),
        ])..applyConnection(
          fromNodeId: 'a',
          target: const InputHit(nodeId: 'y', slot: 0),
          idGenerator: () => 'c2',
        );

    final conns = manager.connections;
    expect(conns.length, equals(2));
    expect(conns.any((c) => c.fromNodeId == 'a' && c.toNodeId == 'x'), isTrue);
    expect(conns.any((c) => c.fromNodeId == 'a' && c.toNodeId == 'y'), isTrue);
  });
}
