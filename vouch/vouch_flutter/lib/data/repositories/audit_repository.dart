import 'package:vouch_client/vouch_client.dart';

abstract class AuditRepository {
  Future<List<AuditEvent>> listRecent(
    int householdId, {
    int page = 0,
    int pageSize = 25,
  });
}

class ServerpodAuditRepository implements AuditRepository {
  ServerpodAuditRepository(this._client);

  final Client _client;

  @override
  Future<List<AuditEvent>> listRecent(
    int householdId, {
    int page = 0,
    int pageSize = 25,
  }) => _client.audit.listRecent(householdId, page: page, pageSize: pageSize);
}
