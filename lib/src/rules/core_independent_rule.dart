import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/lint_utils.dart';
import 'package:clean_arch_lint/src/rules/architecture_import_rule.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';

/// Reports `core` importing `domain` or `data`.
///
/// Core is shared code with no business rule, so it must not know the
/// project's entities or infrastructure. `core` importing `screens` or
/// `presentation` is reported by `no_screens_dependencies`, not here.
///
/// **Severity:** WARNING. Enable `core_independent` under
/// `plugins.clean_arch_lint.diagnostics` (`true` or `error`).
///
/// ```dart
/// // core/utils/price_formatter_util.dart
/// import 'package:my_app/domain/entities/product_entity.dart'; // core_independent
/// import 'package:my_app/data/models/product_model.dart'; // core_independent
/// ```
class CoreIndependentRule extends ArchitectureImportRule {
  /// Creates the rule.
  CoreIndependentRule()
    : super(name: LintNames.coreIndependent, description: 'Core must not import domain or data.');

  @override
  List<DiagnosticCode> get diagnosticCodes => [coreIndependentCode];

  @override
  DiagnosticCode? diagnosticCodeFor(
    ArchitectureLayer currentLayer,
    ArchitectureLayer? importedLayer,
  ) {
    if (currentLayer != .core) return null;
    final isDomainOrData = importedLayer == .domain || importedLayer == .data;
    return isDomainOrData ? coreIndependentCode : null;
  }
}
