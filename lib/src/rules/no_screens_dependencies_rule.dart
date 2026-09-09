import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/lint_utils.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';

/// Single [MultiAnalysisRule] that enforces import boundaries for every layer.
///
/// Former per-layer rules (`core_no_flutter`, `data_no_presentation`,
/// `presentation_no_data`, `domain_only`, …) were collapsed into this visitor
/// so the analyzer registers one processor per `ImportDirective` instead of
/// walking the same file once per rule.
///
/// **Severity:** WARNING. Enable diagnostics under
/// `plugins.clean_arch_lint.diagnostics` (`true` or `error`).
///
/// **Violation examples:**
///
/// ```dart
/// // presentation/pages/product_page.dart
/// import 'package:app/data/models/product_model.dart'; // no_data_dependencies
///
/// // domain/usecases/get_product.dart
/// import 'package:app/data/models/product_model.dart'; // domain_only_depends_on_itself
/// ```
///
/// **Config:**
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
class NoScreensDependenciesRule extends MultiAnalysisRule {
  /// Creates the architecture boundary rule.
  NoScreensDependenciesRule()
    : super(
        name: LintNames.noScreensDependencies,
        description:
            'Enforces Clean Architecture import boundaries across core, '
            'domain, data, presentation, and screens.',
      );

  @override
  List<DiagnosticCode> get diagnosticCodes => [
    noPresentationDependenciesCode,
    noScreensDependenciesCode,
    noDataDependenciesCodeInPresentation,
    noDataDependenciesCodeInScreens,
    domainOnlyDependsOnItselfCode,
  ];

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);

    registry.addImportDirective(this, visitor);
  }
}

enum _ImportType { data, presentation, screens, core, domain }

class _Visitor(final MultiAnalysisRule rule, final RuleContext context)
    extends SimpleAstVisitor<void> {
  @override
  void visitImportDirective(ImportDirective node) {
    final filePath = context.currentUnit?.file.path ?? '';
    final importType = _importType(filePath);
    if (importType == null) return;

    final uri = node.uri.stringValue;
    if (uri == null) return;

    final sourceFilePath = context.definingUnit.file.shortName;
    final projectRoot = extractProjectRoot(sourceFilePath);
    final packageName = extractPackageName(uri);

    final resolved = resolveImport(node, filePath, packageName, projectRoot);

    if (resolved == null) return;
    switch (importType) {
      case _ImportType.data:
        final isImportScreens = importsFromLayer(resolved.resolvedPath, 'screens');
        final isImportPresentation = importsFromLayer(resolved.resolvedPath, 'presentation');
        if (isImportScreens || isImportPresentation) {
          rule.reportAtNode(
            node,
            diagnosticCode: isImportScreens
                ? noDataDependenciesCodeInScreens
                : noDataDependenciesCodeInPresentation,
          );
        }
      case _ImportType.presentation:
        final isImportData = importsFromLayer(resolved.resolvedPath, 'data');
        if (isImportData) {
          rule.reportAtNode(node, diagnosticCode: noDataDependenciesCodeInPresentation);
        }
      case _ImportType.screens:
        final isImportData = importsFromLayer(resolved.resolvedPath, 'data');
        if (isImportData) {
          rule.reportAtNode(node, diagnosticCode: noDataDependenciesCodeInScreens);
        }
      case _ImportType.core:
        final isImportScreens = importsFromLayer(resolved.resolvedPath, 'screens');
        final isImportPresentation = importsFromLayer(resolved.resolvedPath, 'presentation');
        if (isImportScreens || isImportPresentation) {
          rule.reportAtNode(
            node,
            diagnosticCode: isImportScreens
                ? noDataDependenciesCodeInScreens
                : noDataDependenciesCodeInPresentation,
          );
        }
      case _ImportType.domain:
        if (!importsFromLayer(resolved.resolvedPath, 'domain')) {
          rule.reportAtNode(node, diagnosticCode: domainOnlyDependsOnItselfCode);
        }
    }
  }

  _ImportType? _importType(String uri) {
    for (final importType in _ImportType.values) {
      if (isInLayer(uri, importType.name)) {
        return importType;
      }
    }
    return null;
  }
}
