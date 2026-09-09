import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/rules/only_import_visitor.dart';

/// Lint rule that requires the domain layer to depend only on itself.
///
/// Domain is the innermost layer. Other layers import domain; domain must not
/// import data, presentation, core, Flutter, or third-party packages. Dart SDK
/// imports are allowed, except `dart:ui`.
///
/// ## Severity
///
/// WARNING (default) - Can be configured to ERROR via `analysis_options.yaml`
///
/// ## Dependency rule
///
/// ``
/// presentation → domain ← data
/// ``
///
/// Domain should only import other domain types (entities, usecases, contracts).
///
/// ## Configuration
///
/// To transform into ERROR, add to `analysis_options.yaml`:
///
/// ```yaml
/// plugins:
///   clean_arch_lint:
///     diagnostics:
///       domain_only: error # enable to see the error, default is warning
/// ```
///
/// ## Violation example
///
/// ```dart
/// // ⚠️ Warning - domain/usecases/get_user.dart
/// import 'package:my_app/data/repositories/user_repository_impl.dart';
/// import 'package:flutter/material.dart';
///
/// class GetUser {
///   final UserRepositoryImpl repository; // Knows a data implementation
/// }
/// ```
///
/// ## Solution
///
/// ```dart
/// // ✅ Correct - domain/usecases/get_user.dart
/// import 'dart:async';
/// import 'package:my_app/domain/entities/user.dart';
/// import 'package:my_app/domain/contracts/user_repository.dart';
///
/// class GetUser {
///   final UserRepository repository; // Depends on a domain contract
///
///   GetUser(this.repository);
///
///   Future<User> call(String id) => repository.getUser(id);
/// }
/// ```
class DomainOnly extends AnalysisRule {
  /// Creates an instance of the [DomainOnly] rule.
  DomainOnly()
    : super(
        name: 'domain_only',
        description: 'Warns when domain depends on anything other than itself.',
      );
  static const _code = LintCode(
    'domain_only',
    'Domain should only depend on itself.',
    correctionMessage: 'Keep only domain imports (and Dart SDK, except dart:ui). Move UI, data, or third-party code out of domain.',
    severity: .WARNING,
  );
  @override
  DiagnosticCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = OnlyImportVisitor(rule: this, context: context, layer: 'domain');
    registry.addImportDirective(this, visitor);
  }
}
