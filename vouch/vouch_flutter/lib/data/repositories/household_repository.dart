import 'package:vouch_client/vouch_client.dart';

/// Data-layer access to household/member/enrolment reads and the live
/// household event stream. Abstracted behind an interface so widget tests
/// can substitute a fake instead of talking to a real server (see
/// test/fakes/fake_household_repository.dart).
abstract class HouseholdRepository {
  Future<HouseholdOverview> myHousehold();
  Future<List<Member>> members(int householdId);
  Future<List<Enrolment>> enrolments(int householdId);
  Stream<HouseholdEvent> householdStatus(int householdId);

  /// Immediately withdraws [memberId]'s voice trust: the member's status is
  /// set to revoked (blocking future attestations) and every currently-live
  /// attestation for them is revoked too. Owner-only on the server.
  Future<Member> revokeMember(int memberId);

  /// Restores a previously revoked member back to active, so future
  /// attestations can be minted for them again. Owner-only on the server.
  Future<Member> restoreMember(int memberId);
}

class ServerpodHouseholdRepository implements HouseholdRepository {
  ServerpodHouseholdRepository(this._client);

  final Client _client;

  @override
  Future<HouseholdOverview> myHousehold() => _client.household.myHousehold();

  @override
  Future<List<Member>> members(int householdId) =>
      _client.household.members(householdId);

  @override
  Future<List<Enrolment>> enrolments(int householdId) =>
      _client.household.enrolments(householdId);

  @override
  Stream<HouseholdEvent> householdStatus(int householdId) =>
      _client.household.householdStatus(householdId);

  @override
  Future<Member> revokeMember(int memberId) =>
      _client.household.revokeMember(memberId);

  @override
  Future<Member> restoreMember(int memberId) =>
      _client.household.restoreMember(memberId);
}
