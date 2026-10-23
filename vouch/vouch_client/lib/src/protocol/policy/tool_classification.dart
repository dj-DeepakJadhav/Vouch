/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../enums/trust_tier.dart' as _i6oty1c9;

/// A cached risk classification for an MCP tool the household has no
/// explicit rule for and that has no built-in default tier (see
/// `ToolRiskClassifier` and `PolicyEngine`). Computed once (owner-triggered,
/// via `RulesEndpoint.classifyTool`) and reused thereafter rather than
/// calling Nemotron on every guard evaluation.
abstract class ToolClassification
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ToolClassification._({
    this.id,
    required this.toolName,
    required this.tier,
    required this.reason,
    required this.model,
    required this.createdAt,
  });

  factory ToolClassification({
    int? id,
    required String toolName,
    required _i6oty1c9.TrustTier tier,
    required String reason,
    required String model,
    required DateTime createdAt,
  }) = _ToolClassificationImpl;

  factory ToolClassification.fromJson(Map<String, dynamic> jsonSerialization) {
    return ToolClassification(
      id: jsonSerialization['id'] as int?,
      toolName: jsonSerialization['toolName'] as String,
      tier: _i6oty1c9.TrustTier.fromJson((jsonSerialization['tier'] as String)),
      reason: jsonSerialization['reason'] as String,
      model: jsonSerialization['model'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The tool name this classification applies to (global — tool names are
  /// not household-scoped, since the MCP tool catalogue is shared).
  String toolName;

  /// The minimum trust tier this tool was classified as requiring.
  _i6oty1c9.TrustTier tier;

  /// Plain-English reason for the classification, from the model.
  String reason;

  /// The model name that produced this classification.
  String model;

  /// When this classification was computed.
  DateTime createdAt;

  /// Returns a shallow copy of this [ToolClassification]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ToolClassification copyWith({
    int? id,
    String? toolName,
    _i6oty1c9.TrustTier? tier,
    String? reason,
    String? model,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ToolClassification',
      if (id != null) 'id': id,
      'toolName': toolName,
      'tier': tier.toJson(),
      'reason': reason,
      'model': model,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ToolClassification',
      if (id != null) 'id': id,
      'toolName': toolName,
      'tier': tier.toJson(),
      'reason': reason,
      'model': model,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ToolClassificationImpl extends ToolClassification {
  _ToolClassificationImpl({
    int? id,
    required String toolName,
    required _i6oty1c9.TrustTier tier,
    required String reason,
    required String model,
    required DateTime createdAt,
  }) : super._(
         id: id,
         toolName: toolName,
         tier: tier,
         reason: reason,
         model: model,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ToolClassification]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ToolClassification copyWith({
    Object? id = _Undefined,
    String? toolName,
    _i6oty1c9.TrustTier? tier,
    String? reason,
    String? model,
    DateTime? createdAt,
  }) {
    return ToolClassification(
      id: id is int? ? id : this.id,
      toolName: toolName ?? this.toolName,
      tier: tier ?? this.tier,
      reason: reason ?? this.reason,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
