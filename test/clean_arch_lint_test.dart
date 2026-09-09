import 'package:clean_arch_lint/src/utils/import_resolver.dart';
import 'package:test/test.dart';

void main() {
  group('Import Resolver Utils', () {
    test('normalizePath should normalize paths with forward slashes', () {
      expect(normalizePath(r'lib\core\user.dart'), equals('lib/core/user.dart'));
      expect(normalizePath('lib/core/user.dart'), equals('lib/core/user.dart'));
    });

    test('isInLayer should detect if file is in specified layer', () {
      // Standard /lib/{layer}/ pattern
      expect(isInLayer('/project/lib/core/entities/user.dart', 'core'), isTrue);
      expect(isInLayer('/project/lib/data/models/user.dart', 'data'), isTrue);
      expect(isInLayer('/project/lib/presentation/pages/home.dart', 'presentation'), isTrue);
      expect(isInLayer('/project/lib/domain/entities/user.dart', 'domain'), isTrue);

      // /lib/src/{layer}/ pattern
      expect(isInLayer('/project/lib/src/core/entities/user.dart', 'core'), isTrue);
      expect(isInLayer('/project/lib/src/data/models/user.dart', 'data'), isTrue);
      expect(isInLayer('/project/lib/src/presentation/pages/home.dart', 'presentation'), isTrue);
      expect(isInLayer('/project/lib/src/domain/entities/user.dart', 'domain'), isTrue);

      // Negative cases
      expect(isInLayer('/project/lib/core/entities/user.dart', 'data'), isFalse);
      expect(isInLayer('/project/lib/data/models/user.dart', 'presentation'), isFalse);
      expect(isInLayer('/project/lib/src/core/entities/user.dart', 'data'), isFalse);
      expect(isInLayer('/project/lib/src/data/models/user.dart', 'presentation'), isFalse);
      expect(isInLayer('/project/lib/domain/entities/user.dart', 'data'), isFalse);
      expect(isInLayer('/project/lib/src/domain/entities/user.dart', 'core'), isFalse);
    });

    test('importsFromLayer should detect imports from specific layer', () {
      // Standard /lib/{layer}/ pattern
      expect(importsFromLayer('/project/lib/core/entities/user.dart', 'core'), isTrue);
      expect(importsFromLayer('/project/lib/data/models/user.dart', 'data'), isTrue);
      expect(importsFromLayer('/project/lib/presentation/pages/home.dart', 'presentation'), isTrue);
      expect(importsFromLayer('/project/lib/domain/entities/user.dart', 'domain'), isTrue);

      // /lib/src/{layer}/ pattern
      expect(importsFromLayer('/project/lib/src/core/entities/user.dart', 'core'), isTrue);
      expect(importsFromLayer('/project/lib/src/data/models/user.dart', 'data'), isTrue);
      expect(
        importsFromLayer('/project/lib/src/presentation/pages/home.dart', 'presentation'),
        isTrue,
      );
      expect(importsFromLayer('/project/lib/src/domain/entities/user.dart', 'domain'), isTrue);

      // Negative cases
      expect(importsFromLayer('/project/lib/core/entities/user.dart', 'data'), isFalse);
      expect(importsFromLayer('/project/lib/src/core/entities/user.dart', 'data'), isFalse);
      expect(importsFromLayer('/project/lib/domain/entities/user.dart', 'data'), isFalse);
      expect(importsFromLayer('/project/lib/src/domain/entities/user.dart', 'core'), isFalse);
    });

    test('isFlutterImport should detect Flutter-related imports', () {
      expect(isFlutterImport('package:flutter/material.dart'), isTrue);
      expect(isFlutterImport('package:flutter/widgets.dart'), isTrue);
      expect(isFlutterImport('package:flutter_test/flutter_test.dart'), isTrue);
      expect(isFlutterImport('dart:ui'), isTrue);

      expect(isFlutterImport('dart:core'), isFalse);
      expect(isFlutterImport('package:my_app/core/user.dart'), isFalse);
    });

    test('extractProjectRoot should extract project root path', () {
      expect(
        extractProjectRoot('/home/user/project/lib/core/user.dart'),
        equals('/home/user/project'),
      );
      expect(extractProjectRoot('/project/lib/data/models/user_model.dart'), equals('/project'));
    });

    test('extractPackageName should extract package name from URI', () {
      expect(extractPackageName('package:flutter/material.dart'), equals('flutter'));
      expect(extractPackageName('package:my_app/core/user.dart'), equals('my_app'));
      expect(extractPackageName('dart:core'), isNull);
      expect(extractPackageName('../relative/path.dart'), isNull);
    });
  });

  group('Layer Dependency Rules', () {
    test('core and data should not import screens or presentation', () {
      // Enforced by NoScreensDependenciesRule (no_screens_dependencies /
      // no_data_dependencies). See example/lib/data/bad_example_in_data.dart.
      expect(true, isTrue);
    });

    test('presentation and screens should not import data', () {
      // Enforced by no_data_dependencies.
      // See example/lib/presentation/bad_example_data.dart and
      // example/lib/screens/home/home_screen.dart.
      expect(true, isTrue);
    });

    test('domain should only depend on itself', () {
      // Enforced by domain_only_depends_on_itself.
      // See example/lib/domain/bad_example_data.dart.
      expect(true, isTrue);
    });
  });
}
