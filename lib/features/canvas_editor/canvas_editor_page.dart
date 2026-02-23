import 'dart:math' as math;

import 'package:flutter/material.dart' hide Interval;
import 'package:music_notes/music_notes.dart';
import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';
import 'package:notes_playground/features/canvas_editor/domain/node_type_definition.dart';
import 'package:notes_playground/features/canvas_editor/domain/node_type_registry.dart';
import 'package:notes_playground/features/canvas_editor/presentation/node_types/note_node_type.dart';
import 'package:notes_playground/features/canvas_editor/presentation/node_types/transpose_node_type.dart';
import 'package:notes_playground/features/canvas_editor/presentation/node_types/value_node_type.dart';
import 'package:notes_playground/features/canvas_editor/presentation/painters/connections_painter.dart';
import 'package:notes_playground/features/canvas_editor/presentation/widgets/canvas_node_card.dart';
import 'package:uuid/uuid.dart';

@immutable
class CanvasEditorPage extends StatefulWidget {
  const CanvasEditorPage({super.key});

  @override
  State<CanvasEditorPage> createState() => _CanvasEditorPageState();
}

class _CanvasEditorPageState extends State<CanvasEditorPage> {
  static const Uuid _uuid = .new();
  static const double _canvasExtent = 22_000;
  static const double _nodeWidth = 248;

  final NodeTypeRegistry _typeRegistry = .new(
    types: [
      NoteNodeType(),
      TransposeNodeType(),
      ValueNodeType(),
    ],
  );

  final TransformationController _transformController = .new();
  final GlobalKey _viewportKey = .new();

  final Map<String, NodeData<dynamic>> _nodes = {};
  final List<ConnectionData> _connections = [];
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, dynamic> _outputCache = {};

  DraftConnection? _draftConnection;
  String? _selectedConnectionId;
  String? _connectionDragCandidateId;
  Offset? _connectionPointerDownWorld;

  bool _panEnabled = true;

  @override
  void initState() {
    super.initState();
    _seedInitialGraph();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerViewport();
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  NodeTypeDefinition<V, O> _typeForNode<V, O>(NodeData<V> node) {
    return _typeRegistry.byId(node.typeId) as NodeTypeDefinition<V, O>;
  }

  NodeTypeDefinition<V, O> _typeForNodeId<V, O>(String nodeId) {
    final node = _nodes[nodeId] as NodeData<V>?;
    if (node != null) return _typeForNode(node);

    return _typeRegistry.types.first as NodeTypeDefinition<V, O>;
  }

  void _seedInitialGraph() {
    const center = Offset(_canvasExtent / 2, _canvasExtent / 2);

    final note = NodeData(
      id: _uuid.v4(),
      typeId: NoteNodeType.id,
      position: center + const Offset(-340, 0),
      value: Note.a,
    );
    final transpose = NodeData(
      id: _uuid.v4(),
      typeId: TransposeNodeType.id,
      position: center,
      value: Interval.m2,
    );
    final value = NodeData<dynamic>(
      id: _uuid.v4(),
      typeId: ValueNodeType.id,
      position: center + const Offset(340, 0),
    );
    //  final nodeB = NodeData(
    //    id: _uuid.v4(),
    //    typeId: ValueNodeType.id,
    //    position: center + const Offset(-340, 130),
    //    text: 'b',
    //  );
    //  final concat = NodeData(
    //    id: _uuid.v4(),
    //    typeId: ConcatNodeType.id,
    //    position: center + const Offset(20, 30),
    //    text: '',
    //  );
    //  final prefix = NodeData(
    //    id: _uuid.v4(),
    //    typeId: PrefixNodeType.id,
    //    position: center + const Offset(380, 30),
    //    text: 'Result: ',
    //  );

    for (final node in [note, transpose, value]) {
      _nodes[node.id] = node;
      _textControllers[node.id] = TextEditingController(
        text: node.value?.toString(),
      );
    }

    _connections.addAll([
      ConnectionData(
        id: _uuid.v4(),
        fromNodeId: note.id,
        toNodeId: transpose.id,
        toSlot: 0,
      ),
      ConnectionData(
        id: _uuid.v4(),
        fromNodeId: transpose.id,
        toNodeId: value.id,
        toSlot: 0,
      ),
    ]);
  }

  void _centerViewport() {
    final renderObject = _viewportKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    final viewSize = renderObject.size;
    final tx = viewSize.width / 2 - _canvasExtent / 2;
    final ty = viewSize.height / 2 - _canvasExtent / 2;
    _transformController.value = Matrix4.identity()
      ..setTranslationRaw(tx, ty, 0);
  }

  double _nodeHeight(String nodeId) => _typeForNodeId<dynamic, dynamic>(
    nodeId,
  ).nodeHeight(nodeId, _connections);

  int _inputSlots(String nodeId) => _typeForNodeId<dynamic, dynamic>(
    nodeId,
  ).inputSlots(nodeId, _connections);

  Offset _outputPosition(String nodeId) {
    final node = _nodes[nodeId]!;

    return node.position + Offset(_nodeWidth + 8, _nodeHeight(nodeId) / 2);
  }

  Offset _inputPosition(String nodeId, int slot) {
    final node = _nodes[nodeId]!;
    final slots = _inputSlots(nodeId);
    final height = _nodeHeight(nodeId);
    if (slots <= 1) {
      return node.position + Offset(-8, height / 2);
    }

    const top = 52.0;
    final spacing = math.min(26, (height - top - 24) / (slots - 1));

    return node.position + Offset(-8, top + slot * spacing);
  }

  Offset _globalToWorld(Offset globalPosition) {
    final renderObject = _viewportKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return Offset.zero;
    final local = renderObject.globalToLocal(globalPosition);
    final inverse = Matrix4.inverted(_transformController.value);

    return MatrixUtils.transformPoint(inverse, local);
  }

  Path _buildPath(Offset from, Offset to) {
    final dx = (to.dx - from.dx).abs();
    final curvature = 40 + dx * 0.42;
    final c1 = from + Offset(curvature, 0);
    final c2 = to - Offset(curvature, 0);

    return Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, to.dx, to.dy);
  }

  bool _pointNearPath(Path path, Offset point, {required double tolerance}) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final length = metric.length;
      const step = 8.0;
      for (double distance = 0; distance <= length; distance += step) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent == null) continue;
        if ((tangent.position - point).distance <= tolerance) return true;
      }
    }

    return false;
  }

  String? _connectionAt(Offset worldPosition) {
    for (final connection in _connections.reversed) {
      if (_draftConnection?.reconnectingConnectionId == connection.id) {
        continue;
      }

      final path = _buildPath(
        _outputPosition(connection.fromNodeId),
        _inputPosition(connection.toNodeId, connection.toSlot),
      );
      if (_pointNearPath(path, worldPosition, tolerance: 10)) {
        return connection.id;
      }
    }

    return null;
  }

  bool _nodeContains(Offset worldPosition) {
    for (final node in _nodes.values) {
      final rect = Rect.fromLTWH(
        node.position.dx,
        node.position.dy,
        _nodeWidth,
        _nodeHeight(node.id),
      );
      if (rect.contains(worldPosition)) return true;
    }

    return false;
  }

  InputHit? _inputHitAt(Offset worldPosition) {
    for (final node in _nodes.values) {
      final slots = _inputSlots(node.id);
      for (var slot = 0; slot < slots; slot++) {
        final inputPosition = _inputPosition(node.id, slot);
        if ((inputPosition - worldPosition).distance <= 12) {
          return InputHit(nodeId: node.id, slot: slot);
        }
      }
    }

    return null;
  }

  bool _isValidTarget(String fromNodeId, InputHit target) {
    if (fromNodeId == target.nodeId) return false;

    final targetNode = _nodes[target.nodeId];
    if (targetNode == null) return false;

    final targetType = _typeForNode<dynamic, dynamic>(targetNode);
    if (!targetType.acceptsInputConnections) return false;

    if (_wouldCreateCycle(fromNodeId, target.nodeId)) return false;

    return true;
  }

  bool _wouldCreateCycle(String fromNodeId, String toNodeId) {
    final next = <String, List<String>>{};
    for (final connection in _connections) {
      if (_draftConnection?.reconnectingConnectionId == connection.id) {
        continue;
      }
      next
          .putIfAbsent(connection.fromNodeId, () => [])
          .add(connection.toNodeId);
    }

    final visited = <String>{};
    final stack = <String>[toNodeId];
    while (stack.isNotEmpty) {
      final nodeId = stack.removeLast();
      if (!visited.add(nodeId)) continue;
      if (nodeId == fromNodeId) return true;
      stack.addAll(next[nodeId] ?? const []);
    }

    return false;
  }

  void _applyConnection({
    required String fromNodeId,
    required InputHit target,
    String? reconnectingConnectionId,
  }) {
    final targetIndex = _connections.indexWhere(
      (connection) =>
          connection.toNodeId == target.nodeId &&
          connection.toSlot == target.slot,
    );
    if (targetIndex >= 0 &&
        _connections[targetIndex].id != reconnectingConnectionId) {
      _connections.removeAt(targetIndex);
      _outputCache.clear();
    }

    // Allow multiple outgoing connections from the same node, so we do not
    // remove existing outgoing connections here. Each input slot still only
    // accepts a single incoming connection (handled above by removing the
    // targetIndex entry), but a node's output may feed multiple inputs.

    if (reconnectingConnectionId != null) {
      final reconnectIndex = _connections.indexWhere(
        (connection) => connection.id == reconnectingConnectionId,
      );
      if (reconnectIndex >= 0) {
        _connections[reconnectIndex] = _connections[reconnectIndex].copyWith(
          toNodeId: target.nodeId,
          toSlot: target.slot,
        );
        _outputCache.clear();
        return;
      }
    }

    _connections.add(
      ConnectionData(
        id: _uuid.v4(),
        fromNodeId: fromNodeId,
        toNodeId: target.nodeId,
        toSlot: target.slot,
      ),
    );
    _outputCache.clear();
  }

  void _startDraftFromOutput(String fromNodeId, Offset globalPosition) {
    setState(() {
      _draftConnection = DraftConnection(
        fromNodeId: fromNodeId,
        cursorWorld: _globalToWorld(globalPosition),
      );
      _panEnabled = false;
    });
  }

  void _updateDraft(Offset globalPosition) {
    final draft = _draftConnection;
    if (draft == null) return;

    setState(() {
      _draftConnection = draft.copyWith(
        cursorWorld: _globalToWorld(globalPosition),
      );
    });
  }

  void _finishDraft() {
    final draft = _draftConnection;
    if (draft == null) return;

    final target = _inputHitAt(draft.cursorWorld);
    setState(() {
      if (target != null && _isValidTarget(draft.fromNodeId, target)) {
        _applyConnection(
          fromNodeId: draft.fromNodeId,
          target: target,
          reconnectingConnectionId: draft.reconnectingConnectionId,
        );
      } else if (draft.reconnectingConnectionId != null) {
        _connections.removeWhere(
          (connection) => connection.id == draft.reconnectingConnectionId,
        );
        _outputCache.clear();
      }

      _draftConnection = null;
      _connectionDragCandidateId = null;
      _connectionPointerDownWorld = null;
      _panEnabled = true;
    });
  }

  void _addNodeAt(Offset worldPosition) {
    final type = _typeRegistry.cycle(_nodes.length);
    final nodeId = _uuid.v4();
    final height = type.nodeHeight(nodeId, _connections);

    final node = NodeData(
      id: nodeId,
      typeId: type.typeId,
      position: worldPosition - Offset(_nodeWidth / 2, height / 2),
      value: type.defaultValue,
    );

    _textControllers[nodeId] = TextEditingController(
      text: node.value.toString(),
    );
    setState(() {
      _nodes[nodeId] = node;
    });
  }

  Map<String, dynamic> _buildOutputs() {
    // Use a persistent cache to avoid recomputing unchanged nodes.
    final cache = _outputCache;
    final stack = <String>{};

    T? solve<T>(String nodeId) {
      if (cache.containsKey(nodeId)) return cache[nodeId] as T?;
      if (stack.contains(nodeId)) {
        throw Exception('Unsupported cycle detected at node $nodeId');
      }

      final node = _nodes[nodeId];
      if (node == null) return null;

      stack.add(nodeId);
      final incoming =
          _connections
              .where((connection) => connection.toNodeId == nodeId)
              .toList()
            ..sort((a, b) => a.toSlot.compareTo(b.toSlot));

      final inputValues = incoming
          .map((connection) => solve<T>(connection.fromNodeId))
          .toList();

      final output = _typeForNode<dynamic, dynamic>(
        node,
      ).computeOutput(node, inputValues);

      cache[nodeId] = output;
      stack.remove(nodeId);

      return output as T;
    }

    for (final node in _nodes.values) {
      solve<dynamic>(node.id);
    }

    return cache;
  }

  void _invalidateCacheFor(String nodeId) {
    // Remove the given node and all downstream nodes that depend on it.
    final toRemove = <String>{};
    final queue = <String>[nodeId];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (!toRemove.add(current)) continue;
      for (final connection in _connections) {
        if (connection.fromNodeId == current) {
          queue.add(connection.toNodeId);
        }
      }
    }

    toRemove.forEach(_outputCache.remove);
  }

  @override
  Widget build(BuildContext context) {
    final outputs = _buildOutputs();
    final draft = _draftConnection;
    final hoveredInput = draft == null ? null : _inputHitAt(draft.cursorWorld);

    return Scaffold(
      body: GestureDetector(
        onDoubleTapDown: (details) {
          final world = _globalToWorld(details.globalPosition);
          if (!_nodeContains(world)) _addNodeAt(world);
        },
        child: Container(
          key: _viewportKey,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: .topLeft,
              end: .bottomRight,
              colors: [Color(0xFFF8FBF9), Color(0xFFF1F4F3)],
            ),
          ),
          child: InteractiveViewer(
            transformationController: _transformController,
            constrained: false,
            boundaryMargin: const .all(120_000),
            panEnabled: _panEnabled,
            minScale: 0.25,
            maxScale: 2.4,
            child: SizedBox(
              width: _canvasExtent,
              height: _canvasExtent,
              child: Listener(
                onPointerDown: (event) {
                  if (_draftConnection != null) return;

                  final world = _globalToWorld(event.position);
                  final connectionId = _connectionAt(world);
                  setState(() {
                    _selectedConnectionId = connectionId;
                    _connectionDragCandidateId = connectionId;
                    _connectionPointerDownWorld = world;
                  });
                },
                onPointerMove: (event) {
                  if (_draftConnection != null) return;

                  final candidateId = _connectionDragCandidateId;
                  final origin = _connectionPointerDownWorld;
                  if (candidateId == null || origin == null) return;

                  final world = _globalToWorld(event.position);
                  if ((world - origin).distance < 5) return;

                  ConnectionData? connection;
                  for (final item in _connections) {
                    if (item.id == candidateId) {
                      connection = item;
                      break;
                    }
                  }
                  if (connection == null) return;

                  setState(() {
                    _draftConnection = DraftConnection(
                      fromNodeId: connection!.fromNodeId,
                      cursorWorld: world,
                      reconnectingConnectionId: connection.id,
                    );
                    _panEnabled = false;
                  });
                },
                onPointerUp: (_) {
                  if (_draftConnection != null) {
                    _finishDraft();
                    return;
                  }

                  setState(() {
                    _connectionDragCandidateId = null;
                    _connectionPointerDownWorld = null;
                  });
                },
                child: Stack(
                  clipBehavior: .none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ConnectionsPainter(
                          nodes: _nodes,
                          connections: _connections,
                          selectedConnectionId: _selectedConnectionId,
                          draftConnection: draft,
                          outputPositionOf: _outputPosition,
                          inputPositionOf: _inputPosition,
                          buildPath: _buildPath,
                          hoveredInput: hoveredInput,
                          validDrop:
                              draft != null &&
                              hoveredInput != null &&
                              _isValidTarget(draft.fromNodeId, hoveredInput),
                        ),
                      ),
                    ),
                    ..._nodes.values.map((node) {
                      final nodeType = _typeForNode<dynamic, dynamic>(node);
                      final controller = _textControllers[node.id]!;

                      return CanvasNodeCard<dynamic, dynamic>(
                        node: node,
                        nodeType: nodeType,
                        height: _nodeHeight(node.id),
                        width: _nodeWidth,
                        editor: nodeType.buildEditor(
                          output: outputs[node.id],
                          controller: controller,
                          onChanged: (value) => setState(() {
                            final parsed = nodeType.parseValue(value);
                            _nodes[node.id] = _nodes[node.id]!.copyWith(
                              value: parsed ?? value,
                            );
                            _invalidateCacheFor(node.id);
                          }),
                        ),
                        inputSlots: _inputSlots(node.id),
                        inputTopOf: (slot) =>
                            _inputPosition(node.id, slot).dy -
                            node.position.dy -
                            8,
                        outputTop:
                            _outputPosition(node.id).dy - node.position.dy - 8,
                        draft: draft,
                        hoveredInput: hoveredInput,
                        isInputValid: (slot) {
                          final hit = InputHit(nodeId: node.id, slot: slot);
                          final isHovered =
                              hoveredInput?.nodeId == node.id &&
                              hoveredInput?.slot == slot;
                          return draft != null &&
                              isHovered &&
                              _isValidTarget(draft.fromNodeId, hit);
                        },
                        onNodePanStart: (_) => setState(() {
                          _panEnabled = false;
                        }),
                        onNodePanUpdate: (details) {
                          final scale = _transformController.value
                              .getMaxScaleOnAxis();
                          setState(() {
                            final current = _nodes[node.id]!;
                            _nodes[node.id] = current.copyWith(
                              position:
                                  current.position + details.delta / scale,
                            );
                          });
                        },
                        onNodePanEnd: (_) => setState(() {
                          _panEnabled = true;
                        }),
                        onOutputPanStart: (details) => _startDraftFromOutput(
                          node.id,
                          details.globalPosition,
                        ),
                        onOutputPanUpdate: (details) =>
                            _updateDraft(details.globalPosition),
                        onOutputPanEnd: (_) => _finishDraft(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
