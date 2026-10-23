import 'package:vouch_client/vouch_client.dart';

abstract class ApprovalRepository {
  Future<List<Approval>> listPending(int householdId);
  Future<Approval?> decide(int approvalId, bool approve);
  Stream<Approval> pendingApprovals(int householdId);
}

class ServerpodApprovalRepository implements ApprovalRepository {
  ServerpodApprovalRepository(this._client);

  final Client _client;

  @override
  Future<List<Approval>> listPending(int householdId) =>
      _client.approval.listPending(householdId);

  @override
  Future<Approval?> decide(int approvalId, bool approve) =>
      _client.approval.decide(approvalId, approve);

  @override
  Stream<Approval> pendingApprovals(int householdId) =>
      _client.approval.pendingApprovals(householdId);
}
