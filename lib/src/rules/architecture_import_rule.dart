import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';

/// Base for the rules that check `import` directives between architecture
/// layers.
///
/// The analyzer only runs a rule when the diagnostic named after
/// [AbstractAnalysisRule.name] is enabled, so each user-facing diagnostic name
/// needs its own rule. This class resolves the layers of the current file and
/// of the imported library once per import; subclasses only decide, in
/// [diagnosticCodeFor], which code (if any) to report.
abstract class ArchitectureImportRule extends MultiAnalysisRule {
  /// Creates a rule enabled by the diagnostic [name].
  ArchitectureImportRule({required super.name, required super.description});

  /// Returns the code to report when a file in [currentLayer] imports a
  /// library in [importedLayer], or `null` when the import is allowed.
  ///
  /// [importedLayer] is `null` for libraries outside this package's layers
  /// (other packages, or files of this package outside a layer directory).
  /// Libraries in [pureDartLibraries] never reach this method; other `dart:`
  /// libraries arrive with a `null` [importedLayer].
  DiagnosticCode? diagnosticCodeFor(
    ArchitectureLayer currentLayer,
    ArchitectureLayer? importedLayer,
  );

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    registry.addImportDirective(this, _Visitor(this, context));
  }
}

class _Visitor(final ArchitectureImportRule rule, final RuleContext context)
    extends SimpleAstVisitor<void> {
  @override
  void visitImportDirective(ImportDirective node) {
    final currentUri = context.currentUnit?.unit.declaredFragment?.source.uri;
    if (currentUri == null) return;
    final currentLayer = layerOf(currentUri);
    if (currentLayer == null) return;

    final importedUri = importedUriOf(node);
    // Pure Dart libraries are allowed in every layer.
    if (importedUri == null || isPureDartLibrary(importedUri)) return;

    // Only libraries of the same package belong to this project's layers.
    final importedLayer = packageNameOf(importedUri) == packageNameOf(currentUri)
        ? layerOf(importedUri)
        : null;

    final diagnosticCode = rule.diagnosticCodeFor(currentLayer, importedLayer);
    if (diagnosticCode != null) {
      rule.reportAtNode(node, diagnosticCode: diagnosticCode);
    }
  }
}
