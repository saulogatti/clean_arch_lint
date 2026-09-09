import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';

/// A visitor that checks for imports from one layer to another.
///
/// Example:
/// ```dart
/// import 'package:presentation/presentation.dart';
/// import 'package:data/data.dart';
/// ```
///
/// In this example, the visitor will check for imports from the presentation layer to the data layer.
class NoImportVisitor extends SimpleAstVisitor<void> {
  NoImportVisitor({
    required this.rule,
    required this.context,
    required this.exportLayer,
    required this.importLayer,
  });
  final RuleContext context;
  final AnalysisRule rule;

  /// The layer that is exporting the import. Ex: presentation
  final String exportLayer;

  /// The layer that is importing the export. Ex: data
  final String importLayer;
  @override
  void visitImportDirective(ImportDirective node) {
    final filePath = context.currentUnit?.file.path ?? '';
    if (!isInLayer(filePath, exportLayer)) {
      return;
    }

    final uri = node.uri.stringValue;
    if (uri == null) return;

    if (uri.startsWith('dart:') || (uri.startsWith('package:') && uri.contains('/$exportLayer/'))) {
      return;
    }

    final sourceFilePath = context.definingUnit.file.shortName;
    final projectRoot = extractProjectRoot(sourceFilePath);
    final packageName = extractPackageName(uri);

    final resolved = resolveImport(node, filePath, packageName, projectRoot);

    if (resolved == null) return;

    if (importsFromLayer(resolved.resolvedPath, importLayer)) {
      rule.reportAtNode(node);
    }
  }
}
