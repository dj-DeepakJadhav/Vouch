import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:vouch_client/vouch_client.dart';

import '../data/demo_session.dart';
import '../data/hub/hub_client.dart';
import '../data/mcp/mcp_gateway.dart';
import '../data/mcp/mcp_tool_catalog.dart';
import '../data/repositories/demo_repository.dart';
import '../data/repositories/household_repository.dart';
import '../widgets/alexa/verdict_model.dart';

/// Backs the Alexa (simulated Alexa+ surface) screen: mints a demo/dev MCP
/// bearer token, drives real `tools/call` requests against the MCP
/// endpoint, retries on `input_required` (MRTR) until the owner decides or
/// the approval window lapses, and — when "Follow hub" is on — replays
/// whatever utterance the hub just attested as the Alexa command the
/// instant an `attestationAccepted` household event arrives.
class AlexaController extends ChangeNotifier {
  AlexaController({
    required DemoRepository demoRepository,
    required HouseholdRepository householdRepository,
    required this.householdId,
    required this.mcpUrl,
    McpGateway Function({required String mcpUrl, required String token})?
    gatewayFactory,
    HubClient? hubClient,
  }) : _demoRepository = demoRepository,
       _householdRepository = householdRepository,
       _gatewayFactory =
           gatewayFactory ??
           ((({required mcpUrl, required token}) =>
               HttpMcpGateway(mcpUrl: mcpUrl, bearerToken: token))),
       hubClient = hubClient ?? HttpHubClient() {
    // Demo households have no hub to follow; replaying our own test
    // attestations would double-send every command.
    if (isDemo) followHub = false;
  }

  final DemoRepository _demoRepository;
  final HouseholdRepository _householdRepository;
  final int householdId;
  final String mcpUrl;
  final McpGateway Function({required String mcpUrl, required String token})
  _gatewayFactory;

  /// The local hub server (`vouch_hub serve`, 127.0.0.1:8765) that the
  /// "Hold to talk" button (web-only) POSTs recorded audio to. Injectable
  /// for tests (see test/fakes/fake_hub_client.dart).
  final HubClient hubClient;

  /// null = not checked yet, true/false = last `GET /health` outcome.
  bool? hubHealthy;

  McpGateway? _gateway;
  StreamSubscription<HouseholdEvent>? _hubSub;
  Timer? _retryTimer;

  bool followHub = true;

  /// True when running the no-hub "demo household": the speaker picker
  /// issues a signed attestation for the chosen voice before each command.
  bool get isDemo => DemoSession.current != null;
  DemoSpeaker speaker = DemoSpeaker.owner;

  /// The conversation shown on the Alexa screen, oldest first.
  final List<ChatTurn> thread = [];

  void setSpeaker(DemoSpeaker value) {
    speaker = value;
    notifyListeners();
  }

  /// Bumped when a scenario chip picks the speaker, so the picker can flash
  /// the selection instead of changing it silently.
  int speakerFlash = 0;

  /// A scenario chip: selects [value], flashes the picker, then sends.
  Future<void> runScenario(
    DemoSpeaker value,
    String utterance, {
    String? heardByHub,
  }) {
    speaker = value;
    speakerFlash++;
    notifyListeners();
    return sendUtterance(utterance, heardByHub: heardByHub);
  }

  /// Who approves step-ups, as Alexa would name them.
  String get ownerName => DemoSession.current?.ownerName ?? 'the owner';

  String? _error;

  /// The verdict shown in the big panel, derived from the latest trace.
  AlexaVerdict get verdict => buildVerdict(
    lastVouch,
    inFlight: inFlight,
    ownerName: ownerName,
    error: _error,
  );

  String speakerLabel(DemoSpeaker s) {
    final demo = DemoSession.current;
    return switch (s) {
      DemoSpeaker.owner => demo?.ownerName ?? 'Owner',
      DemoSpeaker.child => demo?.childName ?? 'Child',
      DemoSpeaker.tv => 'TV',
    };
  }

  bool minting = false;
  bool inFlight = false;
  String? tokenError;
  List<TraceStep> trace = [];
  String? statusMessage;

  /// MCP Apps (`ui://vouch/verdict`) card HTML, fetched once via
  /// `resources/read` and cached — the resource is a static template (see
  /// vouch_server's verdict_card.dart), per-call data is pushed into it via
  /// `ui/notifications/tool-result` (see verdict_card_view.dart).
  String? verdictCardHtml;

  /// The raw `structuredContent.vouch` map from the most recent result,
  /// used to drive the verdict card (native fallback or postMessage).
  Map<String, dynamic>? lastVouch;

  ({
    String toolName,
    Map<String, dynamic> args,
    String utterance,
    String requestState,
  })?
  _approvedRequest;

  bool get canReplayApprovedRequest =>
      isDemo && !inFlight && _approvedRequest != null;

  /// Re-send the completed approval continuation verbatim. Do not mint
  /// another attestation: this exercises the server's single-use check.
  Future<void> replayApprovedRequest() async {
    if (!canReplayApprovedRequest) return;
    final request = _approvedRequest!;
    _approvedRequest = null;
    inFlight = true;
    trace = [];
    lastVouch = null;
    _error = null;
    statusMessage = 'Re-sending the used approval. No new voice evidence.';
    thread.add(ChatTurn.user('Replay test', request.utterance));
    notifyListeners();
    try {
      final result = await _gateway!.callTool(
        toolName: request.toolName,
        args: request.args,
        utterance: request.utterance,
        requestState: request.requestState,
        inputResponses: const {'confirm': true},
      );
      _applyResult(
        result,
        toolName: request.toolName,
        args: request.args,
        utterance: request.utterance,
      );
    } catch (_) {
      inFlight = false;
      _error = 'The replay test could not reach Vouch. Try a new scenario.';
      statusMessage = _error;
      notifyListeners();
    }
  }

  static const String verdictResourceUri = 'ui://vouch/verdict';

  Future<void> ensureToken() async {
    if (_gateway != null) return;
    minting = true;
    tokenError = null;
    notifyListeners();
    try {
      final token = await _demoRepository.mintMcpToken(householdId);
      _gateway = _gatewayFactory(mcpUrl: mcpUrl, token: token);
    } catch (e) {
      tokenError = '$e';
    }
    minting = false;
    notifyListeners();
  }

  /// Pings the local hub's `/health`. Called once when the Alexa tab opens
  /// so the "Hold to talk" button can show a clear hint when the hub isn't
  /// running, without blocking the rest of the screen.
  Future<void> checkHubHealth() async {
    final healthy = await hubClient.checkHealth();
    hubHealthy = healthy;
    notifyListeners();
  }

  /// Uploads audio recorded by the "Hold to talk" button to the hub
  /// (`POST /utterance`), then feeds the returned transcript through the
  /// same `tools/call` path as typing it in (Follow-hub mode's path).
  /// Rethrows on failure so the button can show its own error state; also
  /// records a status message here for the rest of the screen.
  Future<void> sendRecordedAudio(Uint8List audioBytes, String mimeType) async {
    final HubUtteranceResult result;
    try {
      result = await hubClient.sendUtterance(audioBytes, mimeType);
    } on HubUnreachableException catch (e) {
      hubHealthy = false;
      statusMessage = '$e';
      notifyListeners();
      rethrow;
    }
    hubHealthy = true;
    final transcript = result.transcript;
    if (transcript == null || transcript.isEmpty) {
      statusMessage =
          'The hub could not identify that utterance (${result.status ?? 'no speech'}).';
      notifyListeners();
      return;
    }
    await sendUtterance(transcript);
  }

  void startFollowingHub() {
    if (!followHub) return;
    _hubSub ??= _householdRepository.householdStatus(householdId).listen((
      event,
    ) {
      if (!followHub) return;
      if (event.kind == HouseholdEventKind.attestationAccepted &&
          event.transcript != null &&
          event.transcript!.isNotEmpty) {
        sendUtterance(event.transcript!);
      }
    });
  }

  void setFollowHub(bool value) {
    followHub = value;
    notifyListeners();
    if (value) {
      startFollowingHub();
    }
  }

  /// [heardByHub] is what the hub transcribed when it differs from the text
  /// Alexa sends (a paraphrase); it defaults to [utterance].
  Future<void> sendUtterance(
    String utterance, {
    String? toolNameOverride,
    Map<String, dynamic>? argsOverride,
    String? heardByHub,
  }) async {
    if (inFlight) return;
    _approvedRequest = null;
    await ensureToken();
    final gateway = _gateway;
    if (gateway == null) return;

    if (isDemo) {
      // Show the spoken line immediately, before any result.
      thread.add(ChatTurn.user(speakerLabel(speaker), utterance));
      lastVouch = null;
      _error = null;
      inFlight = true;
      statusMessage = null;
      trace = [];
      notifyListeners();
      final demo = DemoSession.current!;
      final memberId = switch (speaker) {
        DemoSpeaker.owner => demo.ownerMemberId,
        DemoSpeaker.child => demo.childMemberId,
        DemoSpeaker.tv => null,
      };
      if (memberId != null) {
        try {
          await _demoRepository.attest(
            hubId: demo.hubId,
            memberId: memberId,
            utterance: heardByHub ?? utterance,
          );
        } catch (e) {
          // The server refused the attestation (e.g. this member's voice
          // trust is revoked). A real hub's command still reaches Alexa,
          // just unattested, so send it on and let the guard decide.
          debugPrint('demo attestation rejected: $e');
          thread.add(
            ChatTurn.alexa(
              'The hub could not vouch for ${speakerLabel(speaker)} '
              '(voice trust revoked?). Alexa sends the command unattested.',
              blocked: true,
            ),
          );
          notifyListeners();
        }
      }
    }

    final toolName = toolNameOverride ?? inferToolFromUtterance(utterance);
    final args = argsOverride ?? argsFromUtterance(toolName, utterance);

    inFlight = true;
    statusMessage = null;
    trace = [];
    lastVouch = null;
    _error = null;
    notifyListeners();

    final result = await gateway.callTool(
      toolName: toolName,
      args: args,
      utterance: utterance,
    );
    _applyResult(result, toolName: toolName, args: args, utterance: utterance);
  }

  void _applyResult(
    McpCallResult result, {
    required String toolName,
    required Map<String, dynamic> args,
    required String utterance,
    bool retry = false,
    String? completedRequestState,
  }) {
    trace = retry ? mergeRetryTrace(trace, result.steps) : result.steps;
    if (result.vouch != null) {
      lastVouch = retry
          ? mergeRetryVouch(lastVouch, result.vouch)
          : result.vouch;
      unawaited(_ensureVerdictCardHtml());
    }
    switch (result) {
      case McpComplete(:final isError, :final text):
        if (!isError && completedRequestState != null) {
          _approvedRequest = (
            toolName: toolName,
            args: Map<String, dynamic>.unmodifiable(args),
            utterance: utterance,
            requestState: completedRequestState,
          );
        }
        inFlight = false;
        statusMessage = isError && !text.startsWith('Denied')
            ? 'Denied: $text'
            : text;
        _replaceOrAdd(
          ChatTurn.alexa(
            alexaReply(
              lastVouch,
              toolText: text,
              isError: isError,
              ownerName: ownerName,
              toolName: toolName,
            ),
            blocked: isError,
          ),
        );
        notifyListeners();
      case McpProtocolError(:final message):
        inFlight = false;
        _error = message;
        statusMessage = 'Error: $message';
        notifyListeners();
      case McpInputRequired(:final requestState, :final message):
        statusMessage = message;
        _replaceOrAdd(ChatTurn.alexa(waitingReply(ownerName), waiting: true));
        notifyListeners();
        _scheduleRetry(
          requestState: requestState,
          toolName: toolName,
          args: args,
          utterance: utterance,
        );
    }
  }

  /// Alexa's outcome replaces the "waiting" bubble in place (never both).
  void _replaceOrAdd(ChatTurn turn) {
    if (thread.isNotEmpty && thread.last.waiting) {
      thread[thread.length - 1] = turn;
    } else {
      thread.add(turn);
    }
  }

  /// Fetches (once) and caches the `ui://vouch/verdict` MCP Apps resource
  /// HTML via `resources/read`, then notifies listeners so the verdict
  /// card view can (re)render with the latest `lastVouch`.
  Future<void> _ensureVerdictCardHtml() async {
    final gateway = _gateway;
    if (gateway == null) return;
    if (verdictCardHtml == null) {
      verdictCardHtml = await gateway.fetchResourceHtml(verdictResourceUri);
    }
    notifyListeners();
  }

  void _scheduleRetry({
    required String requestState,
    required String toolName,
    required Map<String, dynamic> args,
    required String utterance,
    int attempt = 0,
  }) {
    _retryTimer?.cancel();
    if (attempt >= 30) {
      // ~60s at 2s intervals, matching the server's 60s approval window.
      inFlight = false;
      statusMessage = 'Approval window expired.';
      _replaceOrAdd(
        ChatTurn.alexa(
          "Nobody approved that in time, so I didn't do it.",
          blocked: true,
        ),
      );
      notifyListeners();
      return;
    }
    _retryTimer = Timer(const Duration(seconds: 2), () async {
      final gateway = _gateway;
      if (gateway == null) return;
      final result = await gateway.callTool(
        toolName: toolName,
        args: args,
        utterance: utterance,
        requestState: requestState,
        inputResponses: const {'confirm': true},
      );
      switch (result) {
        case McpInputRequired(:final requestState, :final message):
          trace = mergeRetryTrace(trace, result.steps);
          statusMessage = message;
          if (result.vouch != null) {
            lastVouch = mergeRetryVouch(lastVouch, result.vouch);
            unawaited(_ensureVerdictCardHtml());
          }
          notifyListeners();
          _scheduleRetry(
            requestState: requestState,
            toolName: toolName,
            args: args,
            utterance: utterance,
            attempt: attempt + 1,
          );
        default:
          _applyResult(
            result,
            toolName: toolName,
            args: args,
            utterance: utterance,
            retry: true,
            completedRequestState: requestState,
          );
      }
    });
  }

  @override
  void dispose() {
    _hubSub?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}

/// One line of the simulated Alexa+ conversation.
class ChatTurn {
  const ChatTurn._(
    this.who,
    this.text, {
    this.fromAlexa = false,
    this.blocked = false,
    this.waiting = false,
  });

  factory ChatTurn.user(String who, String text) => ChatTurn._(who, text);
  factory ChatTurn.alexa(
    String text, {
    bool blocked = false,
    bool waiting = false,
  }) => ChatTurn._(
    'Alexa+',
    text,
    fromAlexa: true,
    blocked: blocked,
    waiting: waiting,
  );

  final String who;
  final String text;
  final bool fromAlexa;
  final bool blocked;
  final bool waiting;
}
