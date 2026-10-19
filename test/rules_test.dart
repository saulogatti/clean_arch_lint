// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:clean_arch_lint/clean_arch_lint.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoDataDependenciesRuleTest);
    defineReflectiveTests(NoScreensDependenciesRuleTest);
    defineReflectiveTests(DomainOnlyDependsOnItselfRuleTest);
  });
}

@reflectiveTest
class DomainOnlyDependsOnItselfRuleTest extends _ArchitectureRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = DomainOnlyDependsOnItselfRule();
    newPackage('equatable').addFile('lib/equatable.dart', 'class Equatable {}');
    super.setUp();
  }

  Future<void> test_dartIo_inData() async {
    await assertImports('data/repository.dart', ["import 'dart:io';"], 'File? f;', reported: []);
  }

  Future<void> test_dartIo_inDomain() async {
    const directive = "import 'dart:io';";
    await assertImports('domain/entity.dart', [directive], 'File? f;', reported: [directive]);
  }

  Future<void> test_dartUi() async {
    const directive = "import 'dart:ui';";
    await assertImports('domain/entity.dart', [directive], 'Color? c;', reported: [directive]);
  }

  Future<void> test_data() async {
    const directive = "import 'package:test/data/data_type.dart';";
    await assertImports('domain/entity.dart', [directive], 'DataType? t;', reported: [directive]);
  }

  Future<void> test_domain() async {
    await assertImports(
      'domain/usecase.dart',
      ["import 'package:test/domain/domain_type.dart';", "import 'entity.dart';"],
      'DomainType? t;\nEntity? e;',
      reported: [],
      extraFiles: {'domain/entity.dart': 'class Entity {}'},
    );
  }

  Future<void> test_flutter() async {
    const directive = "import 'package:flutter/widgets.dart';";
    await assertImports('domain/entity.dart', [directive], 'Container? c;', reported: [directive]);
  }

  Future<void> test_pureDartLibraries() async {
    await assertImports(
      'domain/entity.dart',
      ["import 'dart:async';", "import 'dart:math';"],
      'Completer<void>? c;\nfinal p = pi;',
      reported: [],
    );
  }

  Future<void> test_srcLayout() async {
    const directive = "import 'package:test/src/data/data_type.dart';";
    await assertImports(
      'src/domain/entity.dart',
      [directive],
      'DataType? t;',
      reported: [directive],
      extraFiles: {'src/data/data_type.dart': 'class DataType {}'},
    );
  }

  Future<void> test_thirdPartyPackage() async {
    const directive = "import 'package:equatable/equatable.dart';";
    await assertImports('domain/entity.dart', [directive], 'Equatable? e;', reported: [directive]);
  }
}

@reflectiveTest
class NoDataDependenciesRuleTest extends _ArchitectureRuleTest {
  @override
  void setUp() {
    rule = NoDataDependenciesRule();
    newPackage('other').addFile('lib/data/other_type.dart', 'class OtherType {}');
    super.setUp();
  }

  Future<void> test_data_importsPresentation() async {
    await assertImports(
      'data/repository.dart',
      ["import 'package:test/presentation/presentation_type.dart';"],
      'PresentationType? t;',
      reported: [],
    );
  }

  Future<void> test_presentation_importsCoreAndDomain() async {
    await assertImports(
      'presentation/page.dart',
      [
        "import 'package:test/core/core_type.dart';",
        "import 'package:test/domain/domain_type.dart';",
      ],
      'CoreType? c;\nDomainType? d;',
      reported: [],
    );
  }

  Future<void> test_presentation_importsData() async {
    const directive = "import 'package:test/data/data_type.dart';";
    await assertImports(
      'presentation/page.dart',
      [directive],
      'DataType? t;',
      reported: [directive],
    );
  }

  Future<void> test_presentation_importsOtherPackageData() async {
    await assertImports(
      'presentation/page.dart',
      ["import 'package:other/data/other_type.dart';"],
      'OtherType? t;',
      reported: [],
    );
  }

  Future<void> test_screens_importsDataRelative() async {
    const directive = "import '../../data/data_type.dart';";
    await assertImports(
      'screens/home/home.dart',
      [directive],
      'DataType? t;',
      reported: [directive],
    );
  }

  Future<void> test_srcLayout() async {
    const directive = "import '../data/data_type.dart';";
    await assertImports(
      'src/presentation/page.dart',
      [directive],
      'DataType? t;',
      reported: [directive],
      extraFiles: {'src/data/data_type.dart': 'class DataType {}'},
    );
  }

  Future<void> test_testDirectory_importsData() async {
    final file = newFile(
      '$testPackageRootPath/test/page_test.dart',
      "import 'package:test/data/data_type.dart';\n\nDataType? t;\n",
    );
    await assertNoDiagnosticsInFile(file.path);
  }
}

@reflectiveTest
class NoScreensDependenciesRuleTest extends _ArchitectureRuleTest {
  @override
  void setUp() {
    rule = NoScreensDependenciesRule();
    super.setUp();
  }

  Future<void> test_core_importsScreens() async {
    const directive = "import 'package:test/screens/screens_type.dart';";
    await assertImports('core/app.dart', [directive], 'ScreensType? t;', reported: [directive]);
  }

  Future<void> test_data_importsDomain() async {
    await assertImports(
      'data/repository.dart',
      ["import 'package:test/domain/domain_type.dart';"],
      'DomainType? t;',
      reported: [],
    );
  }

  Future<void> test_data_importsPresentation() async {
    const directive = "import '../presentation/presentation_type.dart';";
    await assertImports(
      'data/repository.dart',
      [directive],
      'PresentationType? t;',
      reported: [directive],
    );
  }

  Future<void> test_presentation_importsData() async {
    await assertImports(
      'presentation/page.dart',
      ["import 'package:test/data/data_type.dart';"],
      'DataType? t;',
      reported: [],
    );
  }
}

/// Shared setup: one type per layer under `lib/{layer}/{layer}_type.dart` of
/// the `test` package.
abstract class _ArchitectureRuleTest extends AnalysisRuleTest {
  /// Writes `lib/[path]` with [directives] followed by [body], and asserts
  /// that exactly the directives in [reported] get the rule's lint.
  ///
  /// [body] must use every import, so no `unused_import` warning is reported.
  /// [extraFiles] are written under `lib/` first.
  Future<void> assertImports(
    String path,
    List<String> directives,
    String body, {
    required List<String> reported,
    Map<String, String> extraFiles = const {},
  }) async {
    extraFiles.forEach((extraPath, content) => newFile('$testPackageLibPath/$extraPath', content));

    final content = '${directives.join('\n')}\n\n$body\n';
    final file = newFile('$testPackageLibPath/$path', content);
    await assertDiagnosticsInFile(file.path, [
      for (final directive in reported) lint(content.indexOf(directive), directive.length),
    ]);
  }

  @override
  void setUp() {
    super.setUp();
    for (final layer in ['core', 'data', 'domain', 'presentation', 'screens']) {
      final type = '${layer[0].toUpperCase()}${layer.substring(1)}Type';
      newFile('$testPackageLibPath/$layer/${layer}_type.dart', 'class $type {}');
    }
  }
}
