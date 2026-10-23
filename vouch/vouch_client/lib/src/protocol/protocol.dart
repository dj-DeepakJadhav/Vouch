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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:vouch_client/src/protocol/approval/approval.dart' as _irq51xio;
import 'package:vouch_client/src/protocol/audit/audit_event.dart' as _i3akpdsc;
import 'package:vouch_client/src/protocol/identity/enrolment.dart' as _ixzes3t5;
import 'package:vouch_client/src/protocol/identity/member.dart' as _iijtn340;
import 'package:vouch_client/src/protocol/policy/policy_rule.dart' as _itvg2dtw;
import 'package:vouch_client/src/protocol/policy/rule_proposal.dart'
    as _i6o75vgd;
import 'approval/approval.dart' as _isbdo8a5;
import 'audit/audit_event.dart' as _ijhj7cd7;
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
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

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
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
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
    if (t == _isc.getType<_isbdo8a5.Approval?>()) {
      return (data != null ? _isbdo8a5.Approval.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ijhj7cd7.AuditEvent?>()) {
      return (data != null ? _ijhj7cd7.AuditEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i5ntvuou.DemoStart?>()) {
      return (data != null ? _i5ntvuou.DemoStart.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iu0ezwyc.DemoSeed?>()) {
      return (data != null ? _iu0ezwyc.DemoSeed.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ilsw7efj.ApprovalStatus?>()) {
      return (data != null ? _ilsw7efj.ApprovalStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ij9z5dof.AuditDecision?>()) {
      return (data != null ? _ij9z5dof.AuditDecision.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_irs1kvlr.ChallengeOutcome?>()) {
      return (data != null ? _irs1kvlr.ChallengeOutcome.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_is85fcf9.HouseholdEventKind?>()) {
      return (data != null ? _is85fcf9.HouseholdEventKind.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_icimtxba.MemberRole?>()) {
      return (data != null ? _icimtxba.MemberRole.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izk23120.MemberStatus?>()) {
      return (data != null ? _izk23120.MemberStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ifj3pisi.PolicyEffect?>()) {
      return (data != null ? _ifj3pisi.PolicyEffect.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i0cf6jfj.SpoofRisk?>()) {
      return (data != null ? _i0cf6jfj.SpoofRisk.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i40m9a43.TrustTier?>()) {
      return (data != null ? _i40m9a43.TrustTier.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i6mgtzds.Household?>()) {
      return (data != null ? _i6mgtzds.Household.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4lvvycv.HouseholdEvent?>()) {
      return (data != null ? _i4lvvycv.HouseholdEvent.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i95tyfje.HouseholdOverview?>()) {
      return (data != null ? _i95tyfje.HouseholdOverview.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ir6h6rwa.Attestation?>()) {
      return (data != null ? _ir6h6rwa.Attestation.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iv4umpad.Challenge?>()) {
      return (data != null ? _iv4umpad.Challenge.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i561zpsg.Enrolment?>()) {
      return (data != null ? _i561zpsg.Enrolment.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ipjyaldm.Hub?>()) {
      return (data != null ? _ipjyaldm.Hub.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iqhc56t7.Member?>()) {
      return (data != null ? _iqhc56t7.Member.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i8fbh61f.McpClient?>()) {
      return (data != null ? _i8fbh61f.McpClient.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iohucy14.PairingCode?>()) {
      return (data != null ? _iohucy14.PairingCode.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i3hhpat3.PolicyRule?>()) {
      return (data != null ? _i3hhpat3.PolicyRule.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_irgkqqe0.RulePreviewResult?>()) {
      return (data != null ? _irgkqqe0.RulePreviewResult.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_igyzd6ng.RuleProposal?>()) {
      return (data != null ? _igyzd6ng.RuleProposal.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i3s3zzbq.ToolClassification?>()) {
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
    if (t == List<_irq51xio.Approval>) {
      return (data as List)
              .map((e) => deserialize<_irq51xio.Approval>(e))
              .toList()
          as T;
    }
    if (t == List<_i3akpdsc.AuditEvent>) {
      return (data as List)
              .map((e) => deserialize<_i3akpdsc.AuditEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_iijtn340.Member>) {
      return (data as List)
              .map((e) => deserialize<_iijtn340.Member>(e))
              .toList()
          as T;
    }
    if (t == List<_ixzes3t5.Enrolment>) {
      return (data as List)
              .map((e) => deserialize<_ixzes3t5.Enrolment>(e))
              .toList()
          as T;
    }
    if (t == List<_itvg2dtw.PolicyRule>) {
      return (data as List)
              .map((e) => deserialize<_itvg2dtw.PolicyRule>(e))
              .toList()
          as T;
    }
    if (t == List<_i6o75vgd.RuleProposal>) {
      return (data as List)
              .map((e) => deserialize<_i6o75vgd.RuleProposal>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _isbdo8a5.Approval => 'Approval',
      _ijhj7cd7.AuditEvent => 'AuditEvent',
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
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
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
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('vouch', this);
    _iacc.Protocol().registerHostProtocol('vouch', this);
  }

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
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
