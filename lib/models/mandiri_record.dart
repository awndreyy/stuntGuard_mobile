import 'dart:convert';

/// Snapshot lokal pengecekan mandiri. Tidak pernah disinkronkan ke Laravel.
class MandiriRecord {
  const MandiriRecord({
    this.id,
    required this.accountId,
    required this.childId,
    required this.childName,
    required this.gender,
    required this.measuredAt,
    required this.weight,
    required this.height,
    required this.bodyPosition,
    this.headCircumference,
    this.lila,
    required this.result,
  });

  final int? id;
  final String accountId;
  final String childId;
  final String childName;
  final String gender;
  final DateTime measuredAt;
  final double weight;
  final double height;
  final String bodyPosition;
  final double? headCircumference;
  final double? lila;
  final Map<String, dynamic> result;

  Map<String, Object?> toDatabase() => {
    'account_id': accountId,
    'child_id': childId,
    'child_name': childName,
    'gender': gender,
    'measured_at': measuredAt.toIso8601String(),
    'weight': weight,
    'height': height,
    'body_position': bodyPosition,
    'head_circumference': headCircumference,
    'lila': lila,
    'result_json': jsonEncode(result),
  };

  factory MandiriRecord.fromDatabase(Map<String, Object?> row) => MandiriRecord(
    id: row['id'] as int,
    accountId: row['account_id'] as String,
    childId: row['child_id'] as String,
    childName: row['child_name'] as String,
    gender: row['gender'] as String,
    measuredAt: DateTime.parse(row['measured_at'] as String),
    weight: (row['weight'] as num).toDouble(),
    height: (row['height'] as num).toDouble(),
    bodyPosition: row['body_position'] as String,
    headCircumference: (row['head_circumference'] as num?)?.toDouble(),
    lila: (row['lila'] as num?)?.toDouble(),
    result: Map<String, dynamic>.from(
      jsonDecode(row['result_json'] as String) as Map,
    ),
  );
}
