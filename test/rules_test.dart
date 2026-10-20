// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:analyzer_testing/utilities/utilities.dart';
import 'package:clean_arch_lint/clean_arch_lint.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoDataDependenciesRuleTest);
    defineReflectiveTests(NoScreensDependenciesRuleTest);
    defineReflectiveTests(DomainOnlyDependsOnItselfRuleTest);
    defineReflectiveTests(AllowThirdPartyPackagesInDomainRuleTest);
  });
}

/// `domain_only_depends_on_itself` with `allow_third_party_packages_in_domain`
/// also enabled.
@reflectiveTest
class AllowThirdPartyPackagesInDomainRuleTest extends _ArchitectureRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = DomainOnlyDependsOnItselfRule();
    // AnalysisRuleTest registers and enables only `rule`.
    final option = AllowThirdPartyPackagesInDomainRule();
    Registry.ruleRegistry.registerLintRule(option);
    newPackage('equatable').addFile('lib/equatable.dart', 'class Equatable {}');
    newPackage('other').addFile('lib/data/other_type.dart', 'class OtherType {}');
    super.setUp();
    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      analysisOptionsContent(rules: [rule.name, option.name]),
    );
  }

  Future<void> test_dartIo() async {
    const directive = "import 'dart:io';";
    await assertImports('domain/entity.dart', [directive], 'File? f;', reported: [directive]);
  }

  Future<void> test_data() async {
    const directive = "import 'package:test/data/data_type.dart';";
    await assertImports('domain/entity.dart', [directive], 'DataType? t;', reported: [directive]);
  }

  Future<void> test_flutter() async {
    const directive = "import 'package:flutter/widgets.dart';";
    await assertImports('domain/entity.dart', [directive], 'Container? c;', reported: [directive]);
  }

  Future<void> test_exportThirdPartyPackage() async {
    await assertImports(
      'domain/entity.dart',
      ["export 'package:equatable/equatable.dart';"],
      '',
      reported: [],
    );
  }

  Future<void> test_otherPackageLayer() async {
    await assertImports(
      'domain/entity.dart',
      ["import 'package:other/data/other_type.dart';"],
      'OtherType? t;',
      reported: [],
    );
  }

  Future<void> test_thirdPartyPackage() async {
    await assertImports(
      'domain/entity.dart',
      ["import 'package:equatable/equatable.dart';"],
      'Equatable? e;',
      reported: [],
    );
  }
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

  Future<void> test_exportDomain() async {
    await assertImports(
      'domain/domain.dart',
      ["export 'package:test/domain/domain_type.dart';"],
      '',
      reported: [],
    );
  }

  Future<void> test_exportFlutter() async {
    const directive = "export 'package:flutter/widgets.dart';";
    await assertImports('domain/entity.dart', [directive], '', reported: [directive]);
  }

  Future<void> test_flutter() async {
    const directive = "import 'package:flutter/widgets.dart';";
    await assertImports('domain/entity.dart', [directive], 'Container? c;', reported: [directive]);
  }

  Future<void> test_featureFirst_otherFeatureLayers() async {
    const directive = "import 'package:test/features/product/data/product_model.dart';";
    await assertImports(
      'features/cart/domain/cart_entity.dart',
      ["import 'package:test/features/product/domain/product_entity.dart';", directive],
      'ProductEntity? e;\nProductModel? m;',
      reported: [directive],
      extraFiles: {
        'features/product/domain/product_entity.dart': 'class ProductEntity {}',
        'features/product/data/product_model.dart': 'class ProductModel {}',
      },
    );
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

  Future<void> test_featureFirst_presentation_importsData() async {
    const sameFeature = "import '../data/cart_model.dart';";
    const otherFeature = "import 'package:test/features/product/data/product_model.dart';";
    const topLevel = "import 'package:test/data/data_type.dart';";
    await assertImports(
      'features/cart/presentation/cart_page.dart',
      [sameFeature, otherFeature, topLevel],
      'CartModel? c;\nProductModel? p;\nDataType? d;',
      reported: [sameFeature, otherFeature, topLevel],
      extraFiles: {
        'features/cart/data/cart_model.dart': 'class CartModel {}',
        'features/product/data/product_model.dart': 'class ProductModel {}',
      },
    );
  }

  Future<void> test_featureFirst_presentation_importsOtherFeatureDomain() async {
    await assertImports(
      'src/features/cart/presentation/cart_page.dart',
      ["import 'package:test/src/features/product/domain/product_entity.dart';"],
      'ProductEntity? e;',
      reported: [],
      extraFiles: {'src/features/product/domain/product_entity.dart': 'class ProductEntity {}'},
    );
  }

  Future<void> test_presentation_exportsData() async {
    const directive = "export 'package:test/data/data_type.dart' show DataType;";
    await assertImports('presentation/page.dart', [directive], '', reported: [directive]);
  }

  Future<void> test_presentation_exportsDomain() async {
    await assertImports(
      'presentation/page.dart',
      ["export 'package:test/domain/domain_type.dart';"],
      '',
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

  Future<void> test_data_exportsPresentationRelative() async {
    const directive = "export '../presentation/presentation_type.dart';";
    await assertImports('data/repository.dart', [directive], '', reported: [directive]);
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
    // Offsets come from the stored content: on Windows `newFile` writes `\r\n`.
    final stored = file.readAsStringSync();
    await assertDiagnosticsInFile(file.path, [
      for (final directive in reported) lint(stored.indexOf(directive), directive.length),
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
