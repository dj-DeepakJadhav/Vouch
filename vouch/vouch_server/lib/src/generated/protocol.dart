/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'package:vouch_server/src/generated/approval/approval.dart' as _ib8s1eel;
import 'package:vouch_server/src/generated/audit/audit_event.dart' as _iyg1qwg2;
import 'package:vouch_server/src/generated/identity/enrolment.dart'
    as _igzyiua3;
import 'package:vouch_server/src/generated/identity/member.dart' as _i1mpii2f;
import 'package:vouch_server/src/generated/policy/policy_rule.dart'
    as _ix34xu8v;
import 'package:vouch_server/src/generated/policy/rule_proposal.dart'
    as _i381r595;
import 'approval/approval.dart' as _isbdo8a5;
import 'audit/audit_event.dart' as _ijhj7cd7;
import 'demo/demo_household.dart' as _i8v0d3s6;
import 'demo/demo_start.dart' as _i5ntvuou;
import 'dev/dev_seed.dart' as _iu0ezwyc;
import 'enums/approval_status.dart' as _ilsw7efj;
import 'enums/audit_decision.dart' as _ij9z5dof;
import 'enums/challenge_outcome.dart' as _irs1kvlr;
import 'enums/household_event_kind.dart' as _is85fcf9;
import 'enums/member_role.dart' as _icimtxba;
import 'enums/member_status.dart' as _izk23120;
import 'enums/policy_effect.dart' as _ifj3pisi;
import 'enums/spoof_risk.dart' as _i0cf6jfj;
import 'enums/trust_tier.dart' as _i40m9a43;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'household/household.dart' as _i6mgtzds;
import 'household/household_event.dart' as _i4lvvycv;
import 'household/household_overview.dart' as _i95tyfje;
import 'identity/attestation.dart' as _ir6h6rwa;
import 'identity/challenge.dart' as _iv4umpad;
import 'identity/enrolment.dart' as _i561zpsg;
import 'identity/hub.dart' as _ipjyaldm;
import 'identity/member.dart' as _iqhc56t7;
import 'mcp/mcp_client.dart' as _i8fbh61f;
import 'pairing/pairing_code.dart' as _iohucy14;
import 'policy/policy_rule.dart' as _i3hhpat3;
import 'policy/rule_preview_result.dart' as _irgkqqe0;
import 'policy/rule_proposal.dart' as _igyzd6ng;
import 'policy/tool_classification.dart' as _i3s3zzbq;
export 'approval/approval.dart';
export 'audit/audit_event.dart';
export 'demo/demo_household.dart';
export 'demo/demo_start.dart';
export 'dev/dev_seed.dart';
export 'enums/approval_status.dart';
export 'enums/audit_decision.dart';
export 'enums/challenge_outcome.dart';
export 'enums/household_event_kind.dart';
export 'enums/member_role.dart';
export 'enums/member_status.dart';
export 'enums/policy_effect.dart';
export 'enums/spoof_risk.dart';
export 'enums/trust_tier.dart';
export 'greetings/greeting.dart';
export 'household/household.dart';
export 'household/household_event.dart';
export 'household/household_overview.dart';
export 'identity/attestation.dart';
export 'identity/challenge.dart';
export 'identity/enrolment.dart';
export 'identity/hub.dart';
export 'identity/member.dart';
export 'mcp/mcp_client.dart';
export 'pairing/pairing_code.dart';
export 'policy/policy_rule.dart';
export 'policy/rule_preview_result.dart';
export 'policy/rule_proposal.dart';
export 'policy/tool_classification.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'approval',
      dartName: 'Approval',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'memberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'action',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'argsJson',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'utterance',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'speakerConfidence',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'transcriptMatch',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'heardTranscript',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'transcriptSimilarity',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'requiredTier',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:TrustTier?',
        ),
        _isp.ColumnDefinition(
          name: 'presentTier',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:TrustTier?',
        ),
        _isp.ColumnDefinition(
          name: 'policyReason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'ruleSource',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ApprovalStatus',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'used',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'decidedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'approval_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'approval_fk_1',
          columns: ['memberId'],
          referenceTable: 'member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'approval_household_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'householdId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'attestation',
      dartName: 'Attestation',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'memberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'tier',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TrustTier',
        ),
        _isp.ColumnDefinition(
          name: 'issuedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'confidence',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'spoofRisk',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:SpoofRisk',
        ),
        _isp.ColumnDefinition(
          name: 'hubSig',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'singleUse',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'consumedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'revoked',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'transcriptHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'transcriptNormalised',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'capturedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'attestation_fk_0',
          columns: ['memberId'],
          referenceTable: 'member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'attestation_member_expires_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'memberId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'audit_event',
      dartName: 'AuditEvent',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'memberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'eventType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'action',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'decision',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AuditDecision',
        ),
        _isp.ColumnDefinition(
          name: 'tierRequired',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:TrustTier?',
        ),
        _isp.ColumnDefinition(
          name: 'tierPresent',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:TrustTier?',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'confidence',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'metadata',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'audit_event_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'audit_event_fk_1',
          columns: ['memberId'],
          referenceTable: 'member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'audit_event_household_created_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'householdId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'challenge',
      dartName: 'Challenge',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'memberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'question',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'answerHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'contextSource',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'issuedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'consumedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:ChallengeOutcome?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'challenge_fk_0',
          columns: ['memberId'],
          referenceTable: 'member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'challenge_member_expires_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'memberId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'demo_household',
      dartName: 'DemoHousehold',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'hubId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'ownerAuthUserId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'hubPrivateKeySeed',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'demo_household_household_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'householdId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'demo_household_owner_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'ownerAuthUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'demo_household_created_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'enrolment',
      dartName: 'Enrolment',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'memberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'hubId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'embeddingRef',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'qualityScore',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'sampleCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'enrolledAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'enrolment_fk_0',
          columns: ['memberId'],
          referenceTable: 'member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'enrolment_fk_1',
          columns: ['hubId'],
          referenceTable: 'hub',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'enrolment_member_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'memberId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'household',
      dartName: 'Household',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'hub',
      dartName: 'Hub',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'publicKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'lastSeen',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'hub_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'hub_public_key_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'publicKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'mcp_client',
      dartName: 'McpClient',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'tokenHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'label',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'revoked',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'mcp_client_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'mcp_client_token_hash_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tokenHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'member',
      dartName: 'Member',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MemberRole',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MemberStatus',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'member_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'member_auth_user_id_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'pairing_code',
      dartName: 'PairingCode',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'codeHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'usedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'pairing_code_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'pairing_code_hash_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'codeHash',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'policy_rule',
      dartName: 'PolicyRule',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'householdId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'memberId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'protocol:MemberRole?',
        ),
        _isp.ColumnDefinition(
          name: 'actionPattern',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requiredTier',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TrustTier',
        ),
        _isp.ColumnDefinition(
          name: 'effect',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:PolicyEffect',
          columnDefault: '\'require\'',
        ),
        _isp.ColumnDefinition(
          name: 'sourceText',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'argConditions',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'enabled',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'policy_rule_fk_0',
          columns: ['householdId'],
          referenceTable: 'household',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'policy_rule_fk_1',
          columns: ['memberId'],
          referenceTable: 'member',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'policy_rule_household_action_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'householdId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'actionPattern',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'tool_classification',
      dartName: 'ToolClassification',
      schema: 'public',
      module: 'vouch',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'toolName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'tier',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TrustTier',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'model',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'tool_classification_tool_name_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'toolName',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _isbdo8a5.Approval) {
      return _isbdo8a5.Approval.fromJson(data) as T;
    }
    if (t == _ijhj7cd7.AuditEvent) {
      return _ijhj7cd7.AuditEvent.fromJson(data) as T;
    }
    if (t == _i8v0d3s6.DemoHousehold) {
      return _i8v0d3s6.DemoHousehold.fromJson(data) as T;
    }
    if (t == _i5ntvuou.DemoStart) {
      return _i5ntvuou.DemoStart.fromJson(data) as T;
    }
    if (t == _iu0ezwyc.DemoSeed) {
      return _iu0ezwyc.DemoSeed.fromJson(data) as T;
    }
    if (t == _ilsw7efj.ApprovalStatus) {
      return _ilsw7efj.ApprovalStatus.fromJson(data) as T;
    }
    if (t == _ij9z5dof.AuditDecision) {
      return _ij9z5dof.AuditDecision.fromJson(data) as T;
    }
    if (t == _irs1kvlr.ChallengeOutcome) {
      return _irs1kvlr.ChallengeOutcome.fromJson(data) as T;
    }
    if (t == _is85fcf9.HouseholdEventKind) {
      return _is85fcf9.HouseholdEventKind.fromJson(data) as T;
    }
    if (t == _icimtxba.MemberRole) {
      return _icimtxba.MemberRole.fromJson(data) as T;
    }
    if (t == _izk23120.MemberStatus) {
      return _izk23120.MemberStatus.fromJson(data) as T;
    }
    if (t == _ifj3pisi.PolicyEffect) {
      return _ifj3pisi.PolicyEffect.fromJson(data) as T;
    }
    if (t == _i0cf6jfj.SpoofRisk) {
      return _i0cf6jfj.SpoofRisk.fromJson(data) as T;
    }
    if (t == _i40m9a43.TrustTier) {
      return _i40m9a43.TrustTier.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _i6mgtzds.Household) {
      return _i6mgtzds.Household.fromJson(data) as T;
    }
    if (t == _i4lvvycv.HouseholdEvent) {
      return _i4lvvycv.HouseholdEvent.fromJson(data) as T;
    }
    if (t == _i95tyfje.HouseholdOverview) {
      return _i95tyfje.HouseholdOverview.fromJson(data) as T;
    }
    if (t == _ir6h6rwa.Attestation) {
      return _ir6h6rwa.Attestation.fromJson(data) as T;
    }
    if (t == _iv4umpad.Challenge) {
      return _iv4umpad.Challenge.fromJson(data) as T;
    }
    if (t == _i561zpsg.Enrolment) {
      return _i561zpsg.Enrolment.fromJson(data) as T;
    }
    if (t == _ipjyaldm.Hub) {
      return _ipjyaldm.Hub.fromJson(data) as T;
    }
    if (t == _iqhc56t7.Member) {
      return _iqhc56t7.Member.fromJson(data) as T;
    }
    if (t == _i8fbh61f.McpClient) {
      return _i8fbh61f.McpClient.fromJson(data) as T;
    }
    if (t == _iohucy14.PairingCode) {
      return _iohucy14.PairingCode.fromJson(data) as T;
    }
    if (t == _i3hhpat3.PolicyRule) {
      return _i3hhpat3.PolicyRule.fromJson(data) as T;
    }
    if (t == _irgkqqe0.RulePreviewResult) {
      return _irgkqqe0.RulePreviewResult.fromJson(data) as T;
    }
    if (t == _igyzd6ng.RuleProposal) {
      return _igyzd6ng.RuleProposal.fromJson(data) as T;
    }
    if (t == _i3s3zzbq.ToolClassification) {
      return _i3s3zzbq.ToolClassification.fromJson(data) as T;
    }
    if (t == _is.getType<_isbdo8a5.Approval?>()) {
      return (data != null ? _isbdo8a5.Approval.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijhj7cd7.AuditEvent?>()) {
      return (data != null ? _ijhj7cd7.AuditEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i8v0d3s6.DemoHousehold?>()) {
      return (data != null ? _i8v0d3s6.DemoHousehold.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i5ntvuou.DemoStart?>()) {
      return (data != null ? _i5ntvuou.DemoStart.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iu0ezwyc.DemoSeed?>()) {
      return (data != null ? _iu0ezwyc.DemoSeed.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ilsw7efj.ApprovalStatus?>()) {
      return (data != null ? _ilsw7efj.ApprovalStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ij9z5dof.AuditDecision?>()) {
      return (data != null ? _ij9z5dof.AuditDecision.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_irs1kvlr.ChallengeOutcome?>()) {
      return (data != null ? _irs1kvlr.ChallengeOutcome.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_is85fcf9.HouseholdEventKind?>()) {
      return (data != null ? _is85fcf9.HouseholdEventKind.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_icimtxba.MemberRole?>()) {
      return (data != null ? _icimtxba.MemberRole.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izk23120.MemberStatus?>()) {
      return (data != null ? _izk23120.MemberStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ifj3pisi.PolicyEffect?>()) {
      return (data != null ? _ifj3pisi.PolicyEffect.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i0cf6jfj.SpoofRisk?>()) {
      return (data != null ? _i0cf6jfj.SpoofRisk.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i40m9a43.TrustTier?>()) {
      return (data != null ? _i40m9a43.TrustTier.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6mgtzds.Household?>()) {
      return (data != null ? _i6mgtzds.Household.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4lvvycv.HouseholdEvent?>()) {
      return (data != null ? _i4lvvycv.HouseholdEvent.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i95tyfje.HouseholdOverview?>()) {
      return (data != null ? _i95tyfje.HouseholdOverview.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ir6h6rwa.Attestation?>()) {
      return (data != null ? _ir6h6rwa.Attestation.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iv4umpad.Challenge?>()) {
      return (data != null ? _iv4umpad.Challenge.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i561zpsg.Enrolment?>()) {
      return (data != null ? _i561zpsg.Enrolment.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ipjyaldm.Hub?>()) {
      return (data != null ? _ipjyaldm.Hub.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iqhc56t7.Member?>()) {
      return (data != null ? _iqhc56t7.Member.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i8fbh61f.McpClient?>()) {
      return (data != null ? _i8fbh61f.McpClient.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iohucy14.PairingCode?>()) {
      return (data != null ? _iohucy14.PairingCode.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3hhpat3.PolicyRule?>()) {
      return (data != null ? _i3hhpat3.PolicyRule.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_irgkqqe0.RulePreviewResult?>()) {
      return (data != null ? _irgkqqe0.RulePreviewResult.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_igyzd6ng.RuleProposal?>()) {
      return (data != null ? _igyzd6ng.RuleProposal.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3s3zzbq.ToolClassification?>()) {
      return (data != null ? _i3s3zzbq.ToolClassification.fromJson(data) : null)
          as T;
    }
    if (t == List<_iqhc56t7.Member>) {
      return (data as List)
              .map((e) => deserialize<_iqhc56t7.Member>(e))
              .toList()
          as T;
    }
    if (t == List<_ipjyaldm.Hub>) {
      return (data as List).map((e) => deserialize<_ipjyaldm.Hub>(e)).toList()
          as T;
    }
    if (t == List<_igyzd6ng.RuleProposal>) {
      return (data as List)
              .map((e) => deserialize<_igyzd6ng.RuleProposal>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_ib8s1eel.Approval>) {
      return (data as List)
              .map((e) => deserialize<_ib8s1eel.Approval>(e))
              .toList()
          as T;
    }
    if (t == List<_iyg1qwg2.AuditEvent>) {
      return (data as List)
              .map((e) => deserialize<_iyg1qwg2.AuditEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_i1mpii2f.Member>) {
      return (data as List)
              .map((e) => deserialize<_i1mpii2f.Member>(e))
              .toList()
          as T;
    }
    if (t == List<_igzyiua3.Enrolment>) {
      return (data as List)
              .map((e) => deserialize<_igzyiua3.Enrolment>(e))
              .toList()
          as T;
    }
    if (t == List<_ix34xu8v.PolicyRule>) {
      return (data as List)
              .map((e) => deserialize<_ix34xu8v.PolicyRule>(e))
              .toList()
          as T;
    }
    if (t == List<_i381r595.RuleProposal>) {
      return (data as List)
              .map((e) => deserialize<_i381r595.RuleProposal>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _isbdo8a5.Approval => 'Approval',
      _ijhj7cd7.AuditEvent => 'AuditEvent',
      _i8v0d3s6.DemoHousehold => 'DemoHousehold',
      _i5ntvuou.DemoStart => 'DemoStart',
      _iu0ezwyc.DemoSeed => 'DemoSeed',
      _ilsw7efj.ApprovalStatus => 'ApprovalStatus',
      _ij9z5dof.AuditDecision => 'AuditDecision',
      _irs1kvlr.ChallengeOutcome => 'ChallengeOutcome',
      _is85fcf9.HouseholdEventKind => 'HouseholdEventKind',
      _icimtxba.MemberRole => 'MemberRole',
      _izk23120.MemberStatus => 'MemberStatus',
      _ifj3pisi.PolicyEffect => 'PolicyEffect',
      _i0cf6jfj.SpoofRisk => 'SpoofRisk',
      _i40m9a43.TrustTier => 'TrustTier',
      _izw8z7ou.Greeting => 'Greeting',
      _i6mgtzds.Household => 'Household',
      _i4lvvycv.HouseholdEvent => 'HouseholdEvent',
      _i95tyfje.HouseholdOverview => 'HouseholdOverview',
      _ir6h6rwa.Attestation => 'Attestation',
      _iv4umpad.Challenge => 'Challenge',
      _i561zpsg.Enrolment => 'Enrolment',
      _ipjyaldm.Hub => 'Hub',
      _iqhc56t7.Member => 'Member',
      _i8fbh61f.McpClient => 'McpClient',
      _iohucy14.PairingCode => 'PairingCode',
      _i3hhpat3.PolicyRule => 'PolicyRule',
      _irgkqqe0.RulePreviewResult => 'RulePreviewResult',
      _igyzd6ng.RuleProposal => 'RuleProposal',
      _i3s3zzbq.ToolClassification => 'ToolClassification',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('vouch.', '');
    }

    switch (data) {
      case _isbdo8a5.Approval():
        return 'Approval';
      case _ijhj7cd7.AuditEvent():
        return 'AuditEvent';
      case _i8v0d3s6.DemoHousehold():
        return 'DemoHousehold';
      case _i5ntvuou.DemoStart():
        return 'DemoStart';
      case _iu0ezwyc.DemoSeed():
        return 'DemoSeed';
      case _ilsw7efj.ApprovalStatus():
        return 'ApprovalStatus';
      case _ij9z5dof.AuditDecision():
        return 'AuditDecision';
      case _irs1kvlr.ChallengeOutcome():
        return 'ChallengeOutcome';
      case _is85fcf9.HouseholdEventKind():
        return 'HouseholdEventKind';
      case _icimtxba.MemberRole():
        return 'MemberRole';
      case _izk23120.MemberStatus():
        return 'MemberStatus';
      case _ifj3pisi.PolicyEffect():
        return 'PolicyEffect';
      case _i0cf6jfj.SpoofRisk():
        return 'SpoofRisk';
      case _i40m9a43.TrustTier():
        return 'TrustTier';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _i6mgtzds.Household():
        return 'Household';
      case _i4lvvycv.HouseholdEvent():
        return 'HouseholdEvent';
      case _i95tyfje.HouseholdOverview():
        return 'HouseholdOverview';
      case _ir6h6rwa.Attestation():
        return 'Attestation';
      case _iv4umpad.Challenge():
        return 'Challenge';
      case _i561zpsg.Enrolment():
        return 'Enrolment';
      case _ipjyaldm.Hub():
        return 'Hub';
      case _iqhc56t7.Member():
        return 'Member';
      case _i8fbh61f.McpClient():
        return 'McpClient';
      case _iohucy14.PairingCode():
        return 'PairingCode';
      case _i3hhpat3.PolicyRule():
        return 'PolicyRule';
      case _irgkqqe0.RulePreviewResult():
        return 'RulePreviewResult';
      case _igyzd6ng.RuleProposal():
        return 'RuleProposal';
      case _i3s3zzbq.ToolClassification():
        return 'ToolClassification';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Approval') {
      return deserialize<_isbdo8a5.Approval>(data['data']);
    }
    if (dataClassName == 'AuditEvent') {
      return deserialize<_ijhj7cd7.AuditEvent>(data['data']);
    }
    if (dataClassName == 'DemoHousehold') {
      return deserialize<_i8v0d3s6.DemoHousehold>(data['data']);
    }
    if (dataClassName == 'DemoStart') {
      return deserialize<_i5ntvuou.DemoStart>(data['data']);
    }
    if (dataClassName == 'DemoSeed') {
      return deserialize<_iu0ezwyc.DemoSeed>(data['data']);
    }
    if (dataClassName == 'ApprovalStatus') {
      return deserialize<_ilsw7efj.ApprovalStatus>(data['data']);
    }
    if (dataClassName == 'AuditDecision') {
      return deserialize<_ij9z5dof.AuditDecision>(data['data']);
    }
    if (dataClassName == 'ChallengeOutcome') {
      return deserialize<_irs1kvlr.ChallengeOutcome>(data['data']);
    }
    if (dataClassName == 'HouseholdEventKind') {
      return deserialize<_is85fcf9.HouseholdEventKind>(data['data']);
    }
    if (dataClassName == 'MemberRole') {
      return deserialize<_icimtxba.MemberRole>(data['data']);
    }
    if (dataClassName == 'MemberStatus') {
      return deserialize<_izk23120.MemberStatus>(data['data']);
    }
    if (dataClassName == 'PolicyEffect') {
      return deserialize<_ifj3pisi.PolicyEffect>(data['data']);
    }
    if (dataClassName == 'SpoofRisk') {
      return deserialize<_i0cf6jfj.SpoofRisk>(data['data']);
    }
    if (dataClassName == 'TrustTier') {
      return deserialize<_i40m9a43.TrustTier>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'Household') {
      return deserialize<_i6mgtzds.Household>(data['data']);
    }
    if (dataClassName == 'HouseholdEvent') {
      return deserialize<_i4lvvycv.HouseholdEvent>(data['data']);
    }
    if (dataClassName == 'HouseholdOverview') {
      return deserialize<_i95tyfje.HouseholdOverview>(data['data']);
    }
    if (dataClassName == 'Attestation') {
      return deserialize<_ir6h6rwa.Attestation>(data['data']);
    }
    if (dataClassName == 'Challenge') {
      return deserialize<_iv4umpad.Challenge>(data['data']);
    }
    if (dataClassName == 'Enrolment') {
      return deserialize<_i561zpsg.Enrolment>(data['data']);
    }
    if (dataClassName == 'Hub') {
      return deserialize<_ipjyaldm.Hub>(data['data']);
    }
    if (dataClassName == 'Member') {
      return deserialize<_iqhc56t7.Member>(data['data']);
    }
    if (dataClassName == 'McpClient') {
      return deserialize<_i8fbh61f.McpClient>(data['data']);
    }
    if (dataClassName == 'PairingCode') {
      return deserialize<_iohucy14.PairingCode>(data['data']);
    }
    if (dataClassName == 'PolicyRule') {
      return deserialize<_i3hhpat3.PolicyRule>(data['data']);
    }
    if (dataClassName == 'RulePreviewResult') {
      return deserialize<_irgkqqe0.RulePreviewResult>(data['data']);
    }
    if (dataClassName == 'RuleProposal') {
      return deserialize<_igyzd6ng.RuleProposal>(data['data']);
    }
    if (dataClassName == 'ToolClassification') {
      return deserialize<_i3s3zzbq.ToolClassification>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('vouch', this);
    _iacs.Protocol().registerHostProtocol('vouch', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _isbdo8a5.Approval:
        return _isbdo8a5.Approval.t;
      case _ijhj7cd7.AuditEvent:
        return _ijhj7cd7.AuditEvent.t;
      case _i8v0d3s6.DemoHousehold:
        return _i8v0d3s6.DemoHousehold.t;
      case _i6mgtzds.Household:
        return _i6mgtzds.Household.t;
      case _ir6h6rwa.Attestation:
        return _ir6h6rwa.Attestation.t;
      case _iv4umpad.Challenge:
        return _iv4umpad.Challenge.t;
      case _i561zpsg.Enrolment:
        return _i561zpsg.Enrolment.t;
      case _ipjyaldm.Hub:
        return _ipjyaldm.Hub.t;
      case _iqhc56t7.Member:
        return _iqhc56t7.Member.t;
      case _i8fbh61f.McpClient:
        return _i8fbh61f.McpClient.t;
      case _iohucy14.PairingCode:
        return _iohucy14.PairingCode.t;
      case _i3hhpat3.PolicyRule:
        return _i3hhpat3.PolicyRule.t;
      case _i3s3zzbq.ToolClassification:
        return _i3s3zzbq.ToolClassification.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'vouch';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
