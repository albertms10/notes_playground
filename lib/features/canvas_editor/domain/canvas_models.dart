import 'package:flutter/material.dart';

@immutable
class NodeData<T> {
  const NodeData({
    required this.id,
    required this.typeId,
    this.position = Offset.zero,
    this.value,
  });

  final String id;
  final String typeId;
  final Offset position;
  final T? value;

  NodeData<T> copyWith({
    String? typeId,
    Offset? position,
    T? value,
  }) {
    return NodeData(
      id: id,
      typeId: typeId ?? this.typeId,
      position: position ?? this.position,
      value: value ?? this.value,
    );
  }
}

@immutable
class ConnectionData {
  const ConnectionData({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.toSlot,
  });

  final String id;
  final String fromNodeId;
  final String toNodeId;
  final int toSlot;

  ConnectionData copyWith({
    String? fromNodeId,
    String? toNodeId,
    int? toSlot,
  }) {
    return ConnectionData(
      id: id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      toSlot: toSlot ?? this.toSlot,
    );
  }
}

@immutable
class DraftConnection {
  const DraftConnection({
    required this.fromNodeId,
    required this.cursorWorld,
    this.reconnectingConnectionId,
  });

  final String fromNodeId;
  final Offset cursorWorld;
  final String? reconnectingConnectionId;

  DraftConnection copyWith({Offset? cursorWorld}) => DraftConnection(
    fromNodeId: fromNodeId,
    cursorWorld: cursorWorld ?? this.cursorWorld,
    reconnectingConnectionId: reconnectingConnectionId,
  );
}

@immutable
class InputHit {
  const InputHit({required this.nodeId, required this.slot});

  final String nodeId;
  final int slot;
}
