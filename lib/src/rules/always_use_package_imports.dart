// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

const _desc = 'Avoid relative imports for files in `lib/`.';

class AlwaysUsePackageImports extends AnalysisRule {
  AlwaysUsePackageImports() : super(name: LintNames.always_use_package_imports, description: _desc);

  @override
  DiagnosticCode get diagnosticCode => LintCode(
    LintNames.always_use_package_imports,
    "Use 'package:' imports for files in the 'lib' directory.",
    correctionMessage: "Try converting the URI to a 'package:' URI.",

    uniqueName: 'always_use_package_imports',
  );

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    // Relative paths from outside of the lib folder are handled by the
    // `avoid_relative_lib_imports` lint rule.
    if (!context.isInLibDir) return;

    final visitor = _Visitor(this);
    registry.addImportDirective(this, visitor);
  }
}

class LintNames {
  static String get always_use_package_imports => 'teste_meu';
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);
  final AnalysisRule rule;

  bool isRelativeImport(ImportDirective node) {
    final uriContent = node.uri.stringValue;
    if (uriContent != null) {
      final uri = Uri.tryParse(uriContent);
      return uri != null && uri.scheme.isEmpty;
    }
    return false;
  }

  @override
  void visitImportDirective(ImportDirective node) {
    if (isRelativeImport(node)) {
      rule.reportAtNode(node.uri);
    }
  }
}
