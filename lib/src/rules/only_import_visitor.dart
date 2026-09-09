import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';

/// A visitor that allows only same-layer imports (plus Dart SDK, except Flutter).
///
/// Unlike `NoImportVisitor`, this is an allowlist: any import that is not the
/// Dart SDK (excluding `dart:ui`) and not the configured [layer] is reported.
///
/// Example with `layer: 'domain'`:
/// ```dart
/// import 'dart:async'; // allowed
/// import 'package:my_app/domain/entities/user.dart'; // allowed
/// import 'package:my_app/data/models/user_model.dart'; // reported
/// ```
class OnlyImportVisitor extends SimpleAstVisitor<void> {
  OnlyImportVisitor({required this.rule, required this.context, required this.layer});

  final RuleContext context;
  final AnalysisRule rule;

  /// The only project layer this file may import. Ex: domain
  final String layer;

  @override
  void visitImportDirective(ImportDirective node) {
    final filePath = context.currentUnit?.file.path ?? '';
    if (!isInLayer(filePath, layer)) {
      return;
    }

    final uri = node.uri.stringValue;
    if (uri == null) return;

    if (uri.startsWith('dart:')) {
      if (isFlutterImport(uri)) {
        rule.reportAtNode(node);
      }
      return;
    }

    if (_isSameLayerPackageImport(uri)) {
      return;
    }

    final projectRoot = extractProjectRoot(normalizePath(filePath));
    final packageName = extractPackageName(uri);
    final resolved = resolveImport(node, filePath, packageName, projectRoot);

    if (resolved != null && importsFromLayer(resolved.resolvedPath, layer)) {
      return;
    }

    rule.reportAtNode(node);
  }

  bool _isSameLayerPackageImport(String uri) {
    return uri.startsWith('package:') && uri.contains('/$layer/');
  }
}
