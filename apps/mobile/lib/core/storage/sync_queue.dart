import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.type,
    required this.operation,
    required this.entityId,
    this.localId,
    required this.payload,
    required this.createdAt,
  });

  /// Unique ID for this queued operation.
  final String id;

  /// 'recipe' or 'category'
  final String type;

  /// 'create', 'update', or 'delete'
  final String operation;

  /// The entity's ID. For create ops on offline entities, this is a 'local_…' ID.
  final String entityId;

  /// For create ops only: the locally-generated 'local_…' ID.
  final String? localId;

  /// The request payload (body / named args) to replay against the remote.
  final Map<String, dynamic> payload;

  final DateTime createdAt;

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
        id: json['id'] as String,
        type: json['type'] as String,
        operation: json['operation'] as String,
        entityId: json['entity_id'] as String,
        localId: json['local_id'] as String?,
        payload: (json['payload'] as Map<String, dynamic>?) ?? {},
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'operation': operation,
        'entity_id': entityId,
        'local_id': localId,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Hive-backed persistent queue for operations that need to be synced to the
/// backend once connectivity is restored.
class SyncQueue {
  static const String boxName = 'sync_queue';
  static const Uuid _uuid = Uuid();

  Box<String> get _box => Hive.box<String>(boxName);

  Future<void> enqueue(SyncOperation operation) async {
    await _box.put(operation.id, jsonEncode(operation.toJson()));
  }

  /// Returns all pending operations ordered by creation time (oldest first).
  List<SyncOperation> getAll() {
    return _box.values
        .map((v) {
          try {
            return SyncOperation.fromJson(
              jsonDecode(v) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<SyncOperation>()
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// After a create op is synced, updates all subsequent ops that reference
  /// [localId] to use the real [serverId] so future sync runs are consistent.
  Future<void> replaceEntityId(String localId, String serverId) async {
    final ops =
        getAll().where((op) => op.entityId == localId).toList();
    for (final op in ops) {
      final updated = SyncOperation(
        id: op.id,
        type: op.type,
        operation: op.operation,
        entityId: serverId,
        localId: op.localId,
        payload: op.payload,
        createdAt: op.createdAt,
      );
      await _box.put(op.id, jsonEncode(updated.toJson()));
    }
  }

  Future<void> remove(String operationId) async {
    await _box.delete(operationId);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  bool get isEmpty => _box.isEmpty;
  int get length => _box.length;

  static String generateId() => _uuid.v4();
}
