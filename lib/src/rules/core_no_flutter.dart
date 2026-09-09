import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';

/// Lint rule that prohibits Flutter imports in the core layer.
///
/// The core layer should be completely independent of UI and frameworks,
/// containing only pure business logic. This rule ensures that no
/// code in the core layer imports Flutter or UI-related libraries.
///
/// ## Severity
///
/// ERROR - Violates the fundamental principle of Clean Architecture
///
/// ## Blocked imports
///
/// - `package:flutter/...` (all Flutter imports)
/// - `package:flutter_test/...` (Flutter test library)
/// - `dart:ui` (Dart UI library used by Flutter)
///
/// ## Violation example
///
/// ```dart
/// // ❌ Wrong - core/usecases/get_user.dart
/// import 'package:flutter/material.dart';
///
/// class GetUser {
///   Widget buildWidget() => Container(); // Should not have UI in core
/// }
/// ```
///
/// ## Solution
///
/// ```dart
/// // ✅ Correct - core/usecases/get_user.dart
/// class GetUser {
///   User call(String id) {
///     // Only pure business logic
///   }
/// }
///
/// // ✅ Correct - presentation/widgets/user_widget.dart
/// import 'package:flutter/material.dart';
/// import 'package:my_app/core/usecases/get_user.dart';
///
/// class UserWidget extends StatelessWidget {
///   // UI in the correct layer
/// }
/// ```
class CoreNoFlutter extends AnalysisRule {
  /// Creates an instance of the [CoreNoFlutter] rule.
  CoreNoFlutter()
    : super(name: 'core_no_flutter', description: 'Core cannot depend on Flutter/UI.');
  static const _code = LintCode(
    'core_no_flutter',
    'Core cannot depend on Flutter/UI.',
    correctionMessage: 'Move this code to presentation or abstract it.',
    severity: .WARNING,
  );
  @override
  DiagnosticCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = CoreNoFlutterVisitor(rule: this, context: context);
    registry.addImportDirective(this, visitor);
  }
}

class CoreNoFlutterVisitor extends SimpleAstVisitor {
  CoreNoFlutterVisitor({required this.context, required this.rule});
  final RuleContext context;
  final AnalysisRule rule;
  @override
  void visitImportDirective(ImportDirective node) {
    final filePath = context.currentUnit?.file.path ?? '';
    if (!isInLayer(filePath, 'core')) {
      return;
    }
    final uri = node.uri.stringValue;
    if (uri == null) return;
    if (isFlutterImport(uri)) {
      rule.reportAtNode(node);
    }
  }
}
