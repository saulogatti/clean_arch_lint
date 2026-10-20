import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/lint_utils.dart';
import 'package:clean_arch_lint/src/rules/architecture_import_rule.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';

/// Reports `presentation` or `screens` importing `data`.
///
/// **Severity:** WARNING. Enable `no_data_dependencies` under
/// `plugins.clean_arch_lint.diagnostics` (`true` or `error`).
///
/// ```dart
/// // presentation/pages/product_page.dart
/// import 'package:my_app/data/models/product_model.dart'; // no_data_dependencies
/// ```
class NoDataDependenciesRule extends ArchitectureImportRule {
  /// Creates the rule.
  NoDataDependenciesRule()
    : super(
        name: LintNames.noDataDependencies,
        description: 'Presentation and screens must not import data.',
      );

  @override
  List<DiagnosticCode> get diagnosticCodes => [
    noDataDependenciesCodeInPresentation,
    noDataDependenciesCodeInScreens,
  ];

  @override
  DiagnosticCode? diagnosticCodeFor(
    ArchitectureLayer currentLayer,
    ArchitectureLayer? importedLayer,
  ) {
    if (importedLayer != .data) return null;
    return switch (currentLayer) {
      .presentation => noDataDependenciesCodeInPresentation,
      .screens => noDataDependenciesCodeInScreens,
      _ => null,
    };
  }
}
