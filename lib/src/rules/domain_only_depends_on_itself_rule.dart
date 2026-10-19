import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/lint_utils.dart';
import 'package:clean_arch_lint/src/rules/architecture_import_rule.dart';
import 'package:clean_arch_lint/src/utils/import_resolver.dart';

/// Reports `domain` importing anything outside `domain`, except the
/// [pureDartLibraries] (`dart:core`, `dart:async`, `dart:collection`,
/// `dart:convert`, `dart:math`, `dart:typed_data`).
///
/// Flutter, other `dart:` libraries (`dart:ui`, `dart:io`, ...) and
/// third-party packages are reported too.
///
/// **Severity:** WARNING. Enable `domain_only_depends_on_itself` under
/// `plugins.clean_arch_lint.diagnostics` (`true` or `error`).
///
/// ```dart
/// // domain/usecases/get_product.dart
/// import 'package:app/data/models/product_model.dart'; // domain_only_depends_on_itself
/// import 'package:flutter/material.dart'; // domain_only_depends_on_itself
/// import 'dart:io'; // domain_only_depends_on_itself
/// ```
class DomainOnlyDependsOnItselfRule extends ArchitectureImportRule {
  /// Creates the rule.
  DomainOnlyDependsOnItselfRule()
    : super(
        name: LintNames.domainOnlyDependsOnItself,
        description: 'Domain may import only other domain files and pure Dart libraries.',
      );

  @override
  List<DiagnosticCode> get diagnosticCodes => [domainOnlyDependsOnItselfCode];

  @override
  DiagnosticCode? diagnosticCodeFor(
    ArchitectureLayer currentLayer,
    ArchitectureLayer? importedLayer,
  ) {
    return currentLayer == .domain && importedLayer != .domain
        ? domainOnlyDependsOnItselfCode
        : null;
  }
}
