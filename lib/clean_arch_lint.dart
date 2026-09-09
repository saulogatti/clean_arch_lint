/// Analyzer plugin that enforces Flutter Clean Architecture layer boundaries.
///
/// Isolation is checked by inspecting `import` directives (AST), not by
/// code generation. One [MultiAnalysisRule] covers every layer so the analyzer
/// walks each file once.
///
/// Layers (`lib/{layer}/` or `lib/src/{layer}/`):
///
/// - **domain**: innermost; may import only other domain files (Dart SDK is
///   allowed; Flutter and third-party packages are not)
/// - **core**: must not import `screens` or `presentation`
/// - **data**: must not import `screens` or `presentation`
/// - **presentation**: must not import `data`
/// - **screens**: must not import `data`
///
/// ## Diagnostics
///
/// | Code | When it fires |
/// | --- | --- |
/// | `no_data_dependencies` | `presentation`/`screens` import `data`, or `data`/`core` import UI layers |
/// | `no_screens_dependencies` | `data`/`core` import `screens` or `presentation` |
/// | `domain_only_depends_on_itself` | `domain` imports anything outside `domain` |
///
/// Lint rules from analyzer plugins are **disabled by default**. Enable them
/// in the top-level `plugins` section of `analysis_options.yaml`.
///
/// Local checkout:
///
/// ```yaml
/// plugins:
///   clean_arch_lint:
///     path: ../clean_arch_lint
///     diagnostics:
///       no_data_dependencies: true
///       domain_only_depends_on_itself: true
///       no_screens_dependencies: true
/// ```
///
/// Published package:
///
/// ```yaml
/// plugins:
///   clean_arch_lint:
///     version: ^1.3.0
///     diagnostics:
///       no_data_dependencies: true
///       domain_only_depends_on_itself: true
///       no_screens_dependencies: true
/// ```
///
/// Use `error` instead of `true` to raise severity. Suppress with
/// `// ignore: clean_arch_lint/no_data_dependencies`.
library;

import 'dart:async';

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:clean_arch_lint/src/rules/no_screens_dependencies_rule.dart';

export 'src/rules/no_screens_dependencies_rule.dart' show NoScreensDependenciesRule;

/// Plugin instance loaded by the Dart Analysis Server.
///
/// The server looks for this top-level `plugin` in `lib/main.dart`.
final plugin = CleanArchitectureLintPlugin();

/// Registers [NoScreensDependenciesRule] with the analysis server.
class CleanArchitectureLintPlugin extends Plugin {
  @override
  String get name => 'Flutter Clean Architecture Lint Plugin';

  @override
  FutureOr<void> register(PluginRegistry registry) {
    registry.registerLintRule(NoScreensDependenciesRule());
  }
}
