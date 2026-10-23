import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Thrown for any Nebius Token Factory chat-completion failure. [statusCode]
/// is null for a transport-level failure (timeout, DNS, connection reset).
class NebiusApiException implements Exception {
  const NebiusApiException(this.message, {this.statusCode, this.body});
  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() =>
      'NebiusApiException(${statusCode ?? 'transport'}): $message';
}

/// Raised specifically when the request exceeded [NebiusClient.timeout] (on
/// both the initial attempt and its retry).
class NebiusTimeoutException extends NebiusApiException {
  const NebiusTimeoutException()
    : super('Nebius Token Factory request timed out');
}

/// The result of a chat-completion call: the assistant's text content plus
/// whether the server actually honoured a requested structured-output mode
/// (rather than silently ignoring `response_format` and returning prose).
class NebiusChatResult {
  const NebiusChatResult({
    required this.content,
    required this.structuredOutputHonoured,
    required this.rawResponse,
  });

  /// The assistant message's `content` string (for `json_object`/
  /// `json_schema` modes this is a JSON-encoded string per the OpenAI-
  /// compatible contract; parse it with [jsonDecode]).
  final String content;

  /// True if the request included a `response_format` and the response
  /// did not come back as an error caused by that field (best-effort
  /// signal — see [NebiusClient.supportsStructuredOutput]).
  final bool structuredOutputHonoured;

  /// The full decoded JSON response body, for callers that need more than
  /// `choices[0].message.content` (usage, finish_reason, etc.).
  final Map<String, dynamic> rawResponse;
}

/// The chat-completion surface [NebiusClient] exposes, factored out as an
/// interface so callers that just need "send this prompt, get this result"
/// (e.g. [ToolRiskClassifier]) can be tested against a fake implementation
/// with no real HTTP client, timers, or Nebius credentials involved.
abstract class NebiusChatCompleter {
  Future<NebiusChatResult> chatCompletion({
    required String model,
    required List<Map<String, String>> messages,
    Map<String, dynamic>? responseFormat,
    double temperature = 0.0,
  });
}

/// Thin wrapper around the Nebius Token Factory OpenAI-compatible chat
/// completions endpoint (`POST /chat/completions`, Bearer auth).
///
/// Model name is configurable per call so the same client instance can be
/// used for multiple model choices (e.g. slower/higher-quality vs. fast/cheap).
class NebiusClient implements NebiusChatCompleter {
  NebiusClient({
    required this.apiKey,
    this.baseUrl = 'https://api.tokenfactory.nebius.com/v1',
    this.timeout = const Duration(seconds: 20),
    HttpClient? httpClient,
  }) : _httpClient = httpClient ?? HttpClient();

  final String apiKey;
  final String baseUrl;
  final Duration timeout;
  final HttpClient _httpClient;

  /// Model name for the higher-quality "compiling" tasks (rule compilation).
  static const String modelCompiling = 'nvidia/nemotron-3-super-120b-a12b';

  /// Model name for fast/cheap tasks.
  static const String modelFast = 'nvidia/NVIDIA-Nemotron-3-Nano-30B-A3B';

  /// Sends a chat-completion request. Retries exactly once on a transport
  /// failure (timeout, socket error) or a 5xx response; a 4xx is never
  /// retried (it will not succeed on retry).
  ///
  /// [responseFormat] is passed through verbatim as the OpenAI-compatible
  /// `response_format` field (e.g. `{'type': 'json_object'}` or
  /// `{'type': 'json_schema', 'json_schema': {...}}`), when the caller
  /// wants to attempt structured output. Pass `null` to skip it entirely.
  @override
  Future<NebiusChatResult> chatCompletion({
    required String model,
    required List<Map<String, String>> messages,
    Map<String, dynamic>? responseFormat,
    double temperature = 0.0,
  }) async {
    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      'temperature': temperature,
      if (responseFormat != null) 'response_format': responseFormat,
    };

    try {
      return await _attempt(body, responseFormat != null);
    } on NebiusApiException catch (e) {
      // Never retry a well-formed 4xx client error (bad request, auth) —
      // it is deterministic and will fail again identically.
      if (e.statusCode != null && e.statusCode! < 500) rethrow;
      try {
        return await _attempt(body, responseFormat != null);
      } on NebiusApiException {
        rethrow;
      }
    }
  }

  Future<NebiusChatResult> _attempt(
    Map<String, dynamic> body,
    bool requestedStructured,
  ) async {
    HttpClientRequest request;
    try {
      final uri = Uri.parse('$baseUrl/chat/completions');
      request = await _httpClient
          .postUrl(uri)
          .timeout(
            timeout,
            onTimeout: () => throw const NebiusTimeoutException(),
          );
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=utf-8',
      );
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      // `HttpClientRequest.write` encodes with the request's `Encoding`,
      // which defaults to ASCII when no charset is set on the content type
      // — and household/tool text here routinely contains non-ASCII
      // punctuation (e.g. em dashes). Encode to UTF-8 bytes explicitly so
      // that content is never mangled or rejected.
      request.add(utf8.encode(jsonEncode(body)));

      final response = await request.close().timeout(
        timeout,
        onTimeout: () => throw const NebiusTimeoutException(),
      );
      final responseBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(
            timeout,
            onTimeout: () => throw const NebiusTimeoutException(),
          );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NebiusApiException(
          'Nebius Token Factory returned ${response.statusCode}',
          statusCode: response.statusCode,
          body: responseBody,
        );
      }

      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      } catch (e) {
        throw NebiusApiException(
          'Nebius Token Factory returned non-JSON body: $e',
          statusCode: response.statusCode,
          body: responseBody,
        );
      }

      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) {
        throw NebiusApiException(
          'Nebius Token Factory response had no choices',
          statusCode: response.statusCode,
          body: responseBody,
        );
      }
      final message = (choices.first as Map)['message'] as Map?;
      final content = message?['content'];
      if (content is! String) {
        throw NebiusApiException(
          'Nebius Token Factory response had no message content',
          statusCode: response.statusCode,
          body: responseBody,
        );
      }

      return NebiusChatResult(
        content: content,
        structuredOutputHonoured: requestedStructured,
        rawResponse: decoded,
      );
    } on NebiusApiException {
      rethrow;
    } on TimeoutException {
      throw const NebiusTimeoutException();
    } catch (e) {
      throw NebiusApiException('transport error: $e');
    }
  }

  /// Probes whether [model] accepts `response_format: {'type': 'json_object'}`
  /// without erroring, by issuing a minimal chat-completion call. Returns
  /// `false` (rather than throwing) for any failure — an unsupported
  /// `response_format` typically surfaces as a 4xx from the API, which
  /// this treats as "not supported" so callers can fall back to a strict
  /// prompt + manual parse.
  Future<bool> supportsStructuredOutput(String model) async {
    try {
      await chatCompletion(
        model: model,
        messages: const [
          {
            'role': 'user',
            'content': 'Reply with {"ok": true} and nothing else.',
          },
        ],
        responseFormat: const {'type': 'json_object'},
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
