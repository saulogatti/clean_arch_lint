import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';

/// Base for the rules that check `import` and `export` directives between
/// architecture layers.
///
/// Exports are checked like imports: re-exporting a library leaks it to every
/// file that imports the exporting one.
///
/// The analyzer only runs a rule when the diagnostic named after
/// [AbstractAnalysisRule.name] is enabled, so each user-facing diagnostic name
/// needs its own rule. This class resolves the layers of the current file and
/// of the imported library once per directive; subclasses only decide, in
/// [diagnosticCodeFor], which code (if any) to report.
abstract class ArchitectureImportRule extends MultiAnalysisRule {
  /// Creates a rule enabled by the diagnostic [name].
  ArchitectureImportRule({required super.name, required super.description});

  /// Returns the code to report when a file in [currentLayer] imports or
  /// exports a library in [importedLayer], or `null` when it is allowed.
  ///
  /// [importedLayer] is `null` for libraries outside this project's layers
  /// (packages of other projects, see [isSameProject], or files outside a
  /// layer directory in a package without a layer suffix).
  /// Libraries in [pureDartLibraries] never reach this method; other `dart:`
  /// libraries arrive with a `null` [importedLayer].
  DiagnosticCode? diagnosticCodeFor(
    ArchitectureLayer currentLayer,
    ArchitectureLayer? importedLayer,
  );

  /// Whether the import of [importedUri] by the library at [currentUri] is
  /// allowed regardless of layers, so [diagnosticCodeFor] is not asked.
  ///
  /// Called while visiting, after every enabled rule ran
  /// [registerNodeProcessors] for [context].
  bool isAllowedImport(Uri currentUri, Uri importedUri, RuleContext context) => false;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _Visitor(this, context);
    registry.addImportDirective(this, visitor);
    registry.addExportDirective(this, visitor);
  }
}

class _Visitor(final ArchitectureImportRule rule, final RuleContext context)
    extends SimpleAstVisitor<void> {
  @override
  void visitExportDirective(ExportDirective node) => _check(node, exportedUriOf(node));

  @override
  void visitImportDirective(ImportDirective node) => _check(node, importedUriOf(node));

  /// Reports [node] when the library at [importedUri] is not allowed in the
  /// current file's layer.
  void _check(NamespaceDirective node, Uri? importedUri) {
    final currentUri = context.currentUnit?.unit.declaredFragment?.source.uri;
    if (currentUri == null) return;
    final currentLayer = layerOf(currentUri);
    if (currentLayer == null) return;

    // Pure Dart libraries are allowed in every layer.
    if (importedUri == null || isPureDartLibrary(importedUri)) return;
    if (rule.isAllowedImport(currentUri, importedUri, context)) return;

    // Only libraries of the same project (package, or sibling layer packages)
    // belong to this project's layers.
    final importedLayer = isSameProject(currentUri, importedUri) ? layerOf(importedUri) : null;

    final diagnosticCode = rule.diagnosticCodeFor(currentLayer, importedLayer);
    if (diagnosticCode != null) {
      rule.reportAtNode(node, diagnosticCode: diagnosticCode);
    }
  }
}
