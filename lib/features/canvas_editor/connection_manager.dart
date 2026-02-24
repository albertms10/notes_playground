import 'package:notes_playground/features/canvas_editor/domain/canvas_models.dart';

typedef IdGenerator = String Function();

/// Manages a mutable list of [ConnectionData] and provides operations used by
/// the UI. Kept intentionally small and pure-ish so it can be unit tested.
class ConnectionManager {
  ConnectionManager([List<ConnectionData>? initial])
    : _connections = List.from(initial ?? []);

  final List<ConnectionData> _connections;

  List<ConnectionData> get connections => List.unmodifiable(_connections);

  /// Apply a connection from [fromNodeId] to [target]. This will remove any
  /// existing incoming connection that targets the same node/slot (unless it's
  /// the reconnecting connection). If [reconnectingConnectionId] is provided,
  /// the corresponding connection will be updated instead of added.
  void applyConnection({
    required String fromNodeId,
    required InputHit target,
    required IdGenerator idGenerator,
    String? reconnectingConnectionId,
  }) {
    // Remove existing incoming connection to the target slot
    // (if not reconnecting)
    final targetIndex = _connections.indexWhere(
      (c) => c.toNodeId == target.nodeId && c.toSlot == target.slot,
    );
    if (targetIndex >= 0 &&
        _connections[targetIndex].id != reconnectingConnectionId) {
      _connections.removeAt(targetIndex);
    }

    // If reconnecting, update that connection
    if (reconnectingConnectionId != null) {
      final reconnectIndex = _connections.indexWhere(
        (c) => c.id == reconnectingConnectionId,
      );
      if (reconnectIndex >= 0) {
        _connections[reconnectIndex] = _connections[reconnectIndex].copyWith(
          toNodeId: target.nodeId,
          toSlot: target.slot,
        );
        return;
      }
    }

    // Add new connection. Note: we intentionally allow multiple outgoing
    // connections from the same fromNodeId.
    _connections.add(
      ConnectionData(
        id: idGenerator(),
        fromNodeId: fromNodeId,
        toNodeId: target.nodeId,
        toSlot: target.slot,
      ),
    );
  }

  /// Remove a connection by id. Returns true if removed.
  bool removeById(String id) {
    final index = _connections.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _connections.removeAt(index);
      return true;
    }
    return false;
  }
}
