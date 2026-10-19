import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/lint_utils.dart';
import 'package:clean_arch_lint/src/rules/architecture_import_rule.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';

/// Reports `data` or `core` importing `screens` or `presentation`.
///
/// **Severity:** WARNING. Enable `no_screens_dependencies` under
/// `plugins.clean_arch_lint.diagnostics` (`true` or `error`).
///
/// ```dart
/// // data/repositories/product_repository_impl.dart
/// import 'package:app/presentation/pages/product_page.dart'; // no_screens_dependencies
/// ```
class NoScreensDependenciesRule extends ArchitectureImportRule {
  /// Creates the rule.
  NoScreensDependenciesRule()
    : super(
        name: LintNames.noScreensDependencies,
        description: 'Data and core must not import screens or presentation.',
      );

  @override
  List<DiagnosticCode> get diagnosticCodes => [noScreensDependenciesCode];

  @override
  DiagnosticCode? diagnosticCodeFor(
    ArchitectureLayer currentLayer,
    ArchitectureLayer? importedLayer,
  ) {
    final isDataOrCore = currentLayer == .data || currentLayer == .core;
    final isUi = importedLayer == .screens || importedLayer == .presentation;
    return isDataOrCore && isUi ? noScreensDependenciesCode : null;
  }
}
