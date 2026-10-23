import 'nebius_client.dart';

/// Centralises which Nemotron model a given kind of AI call should use, so
/// the choice is made once and reasoned about in one place rather than
/// scattered as string literals across the policy/mcp packages.
///
/// Rationale: rule compilation (turning ambiguous, adversarial-input plain
/// language into structured policy the household will actually be bound
/// by) is a reasoning-heavy, low-frequency, high-stakes task — it warrants
/// the larger `nemotron-3-super-120b-a12b` ("Super") model, and its extra
/// latency (seconds, not tens of milliseconds) is invisible to the admin
/// confirming a rule. Everything else here is either on a request's hot
/// path (tool-risk classification, called synchronously while Alexa+ is
/// waiting for a tool result) or a simple, well-specified classification
/// task with a small output space — both are better served by the small,
/// fast `NVIDIA-Nemotron-3-Nano-30B-A3B` ("Nano") model, which trades some
/// reasoning depth for much lower latency and cost. Nano's output is
/// always fail-safe-validated (see `ToolRiskClassifier`), so its lower
/// capability never becomes a silent security downgrade.
class ModelRouting {
  const ModelRouting._();

  /// Rule compilation (`RuleCompiler.preview`): plain language -> policy.
  static const String ruleCompilation = NebiusClient.modelCompiling;

  /// Unknown-tool risk classification (`ToolRiskClassifier.classify`): a
  /// fast, bounded (t0/t1/t2) JSON classification, called inline while a
  /// tool call is in flight.
  static const String toolRiskClassification = NebiusClient.modelFast;

  /// Any other fast/cheap classification-shaped call.
  static const String fastClassification = NebiusClient.modelFast;
}
