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
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'package:vouch_server/src/generated/enums/spoof_risk.dart' as _i0hfpm91;
import 'package:vouch_server/src/generated/enums/trust_tier.dart' as _i3bkafhv;
import 'package:vouch_server/src/generated/future_calls.dart' as _imbeztlx;
import 'package:vouch_server/src/generated/policy/rule_proposal.dart'
    as _i381r595;
import '../approval/approval_endpoint.dart' as _ilzm7n4u;
import '../attestation/attestation_endpoint.dart' as _iojsjuov;
import '../audit/audit_endpoint.dart' as _iw8u6495;
import '../auth/anonymous_idp_endpoint.dart' as _in0zita6;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../demo/demo_endpoint.dart' as _i46mxkwc;
import '../dev/dev_endpoint.dart' as _ifx9z153;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
import '../household/household_endpoint.dart' as _ibrq9pgn;
import '../identity/enrolment_endpoint.dart' as _ily13d6g;
import '../pairing/pairing_endpoint.dart' as _iku2870h;
import '../policy/rules_endpoint.dart' as _imo7d8yz;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'approval': _ilzm7n4u.ApprovalEndpoint()
        ..initialize(
          server,
          'approval',
          null,
        ),
      'attestation': _iojsjuov.AttestationEndpoint()
        ..initialize(
          server,
          'attestation',
          null,
        ),
      'audit': _iw8u6495.AuditEndpoint()
        ..initialize(
          server,
          'audit',
          null,
        ),
      'anonymousIdp': _in0zita6.AnonymousIdpEndpoint()
        ..initialize(
          server,
          'anonymousIdp',
          null,
        ),
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'demo': _i46mxkwc.DemoEndpoint()
        ..initialize(
          server,
          'demo',
          null,
        ),
      'dev': _ifx9z153.DevEndpoint()
        ..initialize(
          server,
          'dev',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'household': _ibrq9pgn.HouseholdEndpoint()
        ..initialize(
          server,
          'household',
          null,
        ),
      'enrolment': _ily13d6g.EnrolmentEndpoint()
        ..initialize(
          server,
          'enrolment',
          null,
        ),
      'pairing': _iku2870h.PairingEndpoint()
        ..initialize(
          server,
          'pairing',
          null,
        ),
      'rules': _imo7d8yz.RulesEndpoint()
        ..initialize(
          server,
          'rules',
          null,
        ),
    };
    connectors['approval'] = _is.EndpointConnector(
      name: 'approval',
      endpoint: endpoints['approval']!,
      methodConnectors: {
        'listPending': _is.MethodConnector(
          name: 'listPending',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['approval'] as _ilzm7n4u.ApprovalEndpoint)
                  .listPending(
                    session,
                    params['householdId'],
                  ),
        ),
        'decide': _is.MethodConnector(
          name: 'decide',
          params: {
            'approvalId': _is.ParameterDescription(
              name: 'approvalId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'approve': _is.ParameterDescription(
              name: 'approve',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['approval'] as _ilzm7n4u.ApprovalEndpoint).decide(
                    session,
                    params['approvalId'],
                    params['approve'],
                  ),
        ),
        'pendingApprovals': _is.MethodStreamConnector(
          name: 'pendingApprovals',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['approval'] as _ilzm7n4u.ApprovalEndpoint)
                  .pendingApprovals(
                    session,
                    params['householdId'],
                  ),
        ),
      },
    );
    connectors['attestation'] = _is.EndpointConnector(
      name: 'attestation',
      endpoint: endpoints['attestation']!,
      methodConnectors: {
        'submit': _is.MethodConnector(
          name: 'submit',
          params: {
            'hubId': _is.ParameterDescription(
              name: 'hubId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'tier': _is.ParameterDescription(
              name: 'tier',
              type: _is.getType<_i3bkafhv.TrustTier>(),
              nullable: false,
            ),
            'confidence': _is.ParameterDescription(
              name: 'confidence',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'spoofRisk': _is.ParameterDescription(
              name: 'spoofRisk',
              type: _is.getType<_i0hfpm91.SpoofRisk>(),
              nullable: false,
            ),
            'transcriptNormalised': _is.ParameterDescription(
              name: 'transcriptNormalised',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'capturedAt': _is.ParameterDescription(
              name: 'capturedAt',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'signatureBase64': _is.ParameterDescription(
              name: 'signatureBase64',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attestation'] as _iojsjuov.AttestationEndpoint)
                      .submit(
                        session,
                        hubId: params['hubId'],
                        memberId: params['memberId'],
                        tier: params['tier'],
                        confidence: params['confidence'],
                        spoofRisk: params['spoofRisk'],
                        transcriptNormalised: params['transcriptNormalised'],
                        capturedAt: params['capturedAt'],
                        signatureBase64: params['signatureBase64'],
                      ),
        ),
      },
    );
    connectors['audit'] = _is.EndpointConnector(
      name: 'audit',
      endpoint: endpoints['audit']!,
      methodConnectors: {
        'listRecent': _is.MethodConnector(
          name: 'listRecent',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'page': _is.ParameterDescription(
              name: 'page',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'pageSize': _is.ParameterDescription(
              name: 'pageSize',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['audit'] as _iw8u6495.AuditEndpoint).listRecent(
                    session,
                    params['householdId'],
                    page: params['page'],
                    pageSize: params['pageSize'],
                  ),
        ),
        'exportSince': _is.MethodConnector(
          name: 'exportSince',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'since': _is.ParameterDescription(
              name: 'since',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['audit'] as _iw8u6495.AuditEndpoint).exportSince(
                    session,
                    params['householdId'],
                    params['since'],
                  ),
        ),
      },
    );
    connectors['anonymousIdp'] = _is.EndpointConnector(
      name: 'anonymousIdp',
      endpoint: endpoints['anonymousIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['anonymousIdp'] as _in0zita6.AnonymousIdpEndpoint)
                      .login(
                        session,
                        token: params['token'],
                      ),
        ),
      },
    );
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['demo'] = _is.EndpointConnector(
      name: 'demo',
      endpoint: endpoints['demo']!,
      methodConnectors: {
        'available': _is.MethodConnector(
          name: 'available',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['demo'] as _i46mxkwc.DemoEndpoint)
                  .available(session),
        ),
        'start': _is.MethodConnector(
          name: 'start',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['demo'] as _i46mxkwc.DemoEndpoint).start(session),
        ),
        'attest': _is.MethodConnector(
          name: 'attest',
          params: {
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'utterance': _is.ParameterDescription(
              name: 'utterance',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['demo'] as _i46mxkwc.DemoEndpoint).attest(
                session,
                params['memberId'],
                params['utterance'],
              ),
        ),
        'mintMcpToken': _is.MethodConnector(
          name: 'mintMcpToken',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['demo'] as _i46mxkwc.DemoEndpoint)
                  .mintMcpToken(session),
        ),
      },
    );
    connectors['dev'] = _is.EndpointConnector(
      name: 'dev',
      endpoint: endpoints['dev']!,
      methodConnectors: {
        'demoAvailable': _is.MethodConnector(
          name: 'demoAvailable',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dev'] as _ifx9z153.DevEndpoint)
                  .demoAvailable(session),
        ),
        'seedDemoHousehold': _is.MethodConnector(
          name: 'seedDemoHousehold',
          params: {
            'ownerName': _is.ParameterDescription(
              name: 'ownerName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'childName': _is.ParameterDescription(
              name: 'childName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'hubPublicKeyBase64': _is.ParameterDescription(
              name: 'hubPublicKeyBase64',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['dev'] as _ifx9z153.DevEndpoint).seedDemoHousehold(
                    session,
                    params['ownerName'],
                    params['childName'],
                    params['hubPublicKeyBase64'],
                  ),
        ),
        'approveAsOwner': _is.MethodConnector(
          name: 'approveAsOwner',
          params: {
            'approvalId': _is.ParameterDescription(
              name: 'approvalId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['dev'] as _ifx9z153.DevEndpoint).approveAsOwner(
                    session,
                    params['approvalId'],
                  ),
        ),
        'latestPendingApprovalId': _is.MethodConnector(
          name: 'latestPendingApprovalId',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dev'] as _ifx9z153.DevEndpoint)
                  .latestPendingApprovalId(
                    session,
                    params['householdId'],
                  ),
        ),
        'issueTestAttestation': _is.MethodConnector(
          name: 'issueTestAttestation',
          params: {
            'hubId': _is.ParameterDescription(
              name: 'hubId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'tier': _is.ParameterDescription(
              name: 'tier',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'utterance': _is.ParameterDescription(
              name: 'utterance',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dev'] as _ifx9z153.DevEndpoint)
                  .issueTestAttestation(
                    session,
                    params['hubId'],
                    params['memberId'],
                    params['tier'],
                    params['utterance'],
                  ),
        ),
        'claimOwner': _is.MethodConnector(
          name: 'claimOwner',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dev'] as _ifx9z153.DevEndpoint).claimOwner(
                session,
                params['householdId'],
              ),
        ),
        'mintMcpToken': _is.MethodConnector(
          name: 'mintMcpToken',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['dev'] as _ifx9z153.DevEndpoint).mintMcpToken(
                    session,
                    params['householdId'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    connectors['household'] = _is.EndpointConnector(
      name: 'household',
      endpoint: endpoints['household']!,
      methodConnectors: {
        'hasHousehold': _is.MethodConnector(
          name: 'hasHousehold',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _ibrq9pgn.HouseholdEndpoint)
                  .hasHousehold(session),
        ),
        'myHousehold': _is.MethodConnector(
          name: 'myHousehold',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _ibrq9pgn.HouseholdEndpoint)
                  .myHousehold(session),
        ),
        'members': _is.MethodConnector(
          name: 'members',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _ibrq9pgn.HouseholdEndpoint)
                  .members(
                    session,
                    params['householdId'],
                  ),
        ),
        'enrolments': _is.MethodConnector(
          name: 'enrolments',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _ibrq9pgn.HouseholdEndpoint)
                  .enrolments(
                    session,
                    params['householdId'],
                  ),
        ),
        'revokeMember': _is.MethodConnector(
          name: 'revokeMember',
          params: {
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _ibrq9pgn.HouseholdEndpoint)
                  .revokeMember(
                    session,
                    params['memberId'],
                  ),
        ),
        'restoreMember': _is.MethodConnector(
          name: 'restoreMember',
          params: {
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['household'] as _ibrq9pgn.HouseholdEndpoint)
                  .restoreMember(
                    session,
                    params['memberId'],
                  ),
        ),
        'householdStatus': _is.MethodStreamConnector(
          name: 'householdStatus',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['household'] as _ibrq9pgn.HouseholdEndpoint)
                  .householdStatus(
                    session,
                    params['householdId'],
                  ),
        ),
      },
    );
    connectors['enrolment'] = _is.EndpointConnector(
      name: 'enrolment',
      endpoint: endpoints['enrolment']!,
      methodConnectors: {
        'report': _is.MethodConnector(
          name: 'report',
          params: {
            'hubId': _is.ParameterDescription(
              name: 'hubId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'memberId': _is.ParameterDescription(
              name: 'memberId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'embeddingRef': _is.ParameterDescription(
              name: 'embeddingRef',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'qualityScore': _is.ParameterDescription(
              name: 'qualityScore',
              type: _is.getType<double>(),
              nullable: false,
            ),
            'sampleCount': _is.ParameterDescription(
              name: 'sampleCount',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'capturedAt': _is.ParameterDescription(
              name: 'capturedAt',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'signatureBase64': _is.ParameterDescription(
              name: 'signatureBase64',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['enrolment'] as _ily13d6g.EnrolmentEndpoint)
                  .report(
                    session,
                    hubId: params['hubId'],
                    memberId: params['memberId'],
                    embeddingRef: params['embeddingRef'],
                    qualityScore: params['qualityScore'],
                    sampleCount: params['sampleCount'],
                    capturedAt: params['capturedAt'],
                    signatureBase64: params['signatureBase64'],
                  ),
        ),
      },
    );
    connectors['pairing'] = _is.EndpointConnector(
      name: 'pairing',
      endpoint: endpoints['pairing']!,
      methodConnectors: {
        'createCode': _is.MethodConnector(
          name: 'createCode',
          params: {
            'hubId': _is.ParameterDescription(
              name: 'hubId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'capturedAt': _is.ParameterDescription(
              name: 'capturedAt',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
            'signatureBase64': _is.ParameterDescription(
              name: 'signatureBase64',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['pairing'] as _iku2870h.PairingEndpoint)
                  .createCode(
                    session,
                    hubId: params['hubId'],
                    capturedAt: params['capturedAt'],
                    signatureBase64: params['signatureBase64'],
                  ),
        ),
        'redeem': _is.MethodConnector(
          name: 'redeem',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['pairing'] as _iku2870h.PairingEndpoint).redeem(
                    session,
                    params['code'],
                  ),
        ),
      },
    );
    connectors['rules'] = _is.EndpointConnector(
      name: 'rules',
      endpoint: endpoints['rules']!,
      methodConnectors: {
        'preview': _is.MethodConnector(
          name: 'preview',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'text': _is.ParameterDescription(
              name: 'text',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['rules'] as _imo7d8yz.RulesEndpoint).preview(
                    session,
                    params['householdId'],
                    params['text'],
                  ),
        ),
        'confirm': _is.MethodConnector(
          name: 'confirm',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'proposals': _is.ParameterDescription(
              name: 'proposals',
              type: _is.getType<List<_i381r595.RuleProposal>>(),
              nullable: false,
            ),
            'sourceText': _is.ParameterDescription(
              name: 'sourceText',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['rules'] as _imo7d8yz.RulesEndpoint).confirm(
                    session,
                    params['householdId'],
                    params['proposals'],
                    params['sourceText'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['rules'] as _imo7d8yz.RulesEndpoint).list(
                session,
                params['householdId'],
              ),
        ),
        'disable': _is.MethodConnector(
          name: 'disable',
          params: {
            'ruleId': _is.ParameterDescription(
              name: 'ruleId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['rules'] as _imo7d8yz.RulesEndpoint).disable(
                    session,
                    params['ruleId'],
                  ),
        ),
        'classifyTool': _is.MethodConnector(
          name: 'classifyTool',
          params: {
            'householdId': _is.ParameterDescription(
              name: 'householdId',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'description': _is.ParameterDescription(
              name: 'description',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'inputSchemaJson': _is.ParameterDescription(
              name: 'inputSchemaJson',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['rules'] as _imo7d8yz.RulesEndpoint).classifyTool(
                    session,
                    params['householdId'],
                    params['name'],
                    params['description'],
                    params['inputSchemaJson'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _imbeztlx.FutureCalls();
  }
}
