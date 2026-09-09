import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/lint_utils.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';
import 'package:clean_arch_lint/src/utils/logger_util.dart';

final logger = LoggerUtil(
  fileName: 'no_screens_dependencies_rule_${DateTime.now().millisecondsSinceEpoch}',
);

class NoScreensDependenciesRule extends MultiAnalysisRule {
  /// Creates an instance of the [NoScreensDependenciesRule] rule.
  NoScreensDependenciesRule()
    : super(
        name: LintNames.noScreensDependencies,
        description: 'Warns when screen directly depends on data.',
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

    if (importsFromLayer(resolved.resolvedPath, 'data')) {
      rule.reportAtNode(node, diagnosticCode: noScreensDependenciesCode);
    }
  }

  _ImportType? _importType(String uri) {
    logger.log('uri: $uri');
    for (final importType in _ImportType.values) {
      if (isInLayer(uri, importType.name)) {
        return importType;
      }
    }
    return null;
  }
}
