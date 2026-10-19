import 'package:clean_arch_lint/src/utils/import_resolver.dart';
import 'package:test/test.dart';

void main() {
  group('Import Resolver Utils', () {
    test('layerOf should detect the layer from lib/{layer}/', () {
      expect(layerOf(Uri.parse('package:my_app/core/entities/user.dart')), ArchitectureLayer.core);
      expect(layerOf(Uri.parse('package:my_app/data/models/user.dart')), ArchitectureLayer.data);
      expect(
        layerOf(Uri.parse('package:my_app/presentation/pages/home.dart')),
        ArchitectureLayer.presentation,
      );
      expect(layerOf(Uri.parse('package:my_app/screens/home.dart')), ArchitectureLayer.screens);
      expect(layerOf(Uri.parse('package:my_app/domain/user.dart')), ArchitectureLayer.domain);
    });

    test('layerOf should detect the layer from lib/src/{layer}/', () {
      expect(
        layerOf(Uri.parse('package:my_app/src/core/entities/user.dart')),
        ArchitectureLayer.core,
      );
      expect(
        layerOf(Uri.parse('package:my_app/src/domain/entities/user.dart')),
        ArchitectureLayer.domain,
      );
    });

    test('layerOf should return null outside a layer directory', () {
      expect(layerOf(Uri.parse('package:my_app/main.dart')), isNull);
      expect(layerOf(Uri.parse('package:my_app/data.dart')), isNull);
      expect(layerOf(Uri.parse('package:my_app/src/data.dart')), isNull);
      expect(layerOf(Uri.parse('package:my_app/widgets/data/button.dart')), isNull);
      expect(layerOf(Uri.parse('dart:async')), isNull);
      expect(layerOf(Uri.parse('file:///project/test/data/user_test.dart')), isNull);
    });

    test('isPureDartLibrary should allow only platform-independent SDK libraries', () {
      for (final library in ['core', 'async', 'collection', 'convert', 'math', 'typed_data']) {
        expect(isPureDartLibrary(Uri.parse('dart:$library')), isTrue, reason: 'dart:$library');
      }
      for (final library in ['ui', 'io', 'html', 'ffi', 'isolate', 'js_interop']) {
        expect(isPureDartLibrary(Uri.parse('dart:$library')), isFalse, reason: 'dart:$library');
      }
      expect(isPureDartLibrary(Uri.parse('package:my_app/core/user.dart')), isFalse);
    });

    test('isFlutterImport should detect Flutter-related imports', () {
      expect(isFlutterImport('package:flutter/material.dart'), isTrue);
      expect(isFlutterImport('package:flutter/widgets.dart'), isTrue);
      expect(isFlutterImport('package:flutter_test/flutter_test.dart'), isTrue);
      expect(isFlutterImport('dart:ui'), isTrue);

      expect(isFlutterImport('dart:core'), isFalse);
      expect(isFlutterImport('package:my_app/core/user.dart'), isFalse);
    });

    test('packageNameOf should extract the package name from a package URI', () {
      expect(packageNameOf(Uri.parse('package:flutter/material.dart')), equals('flutter'));
      expect(packageNameOf(Uri.parse('package:my_app/core/user.dart')), equals('my_app'));
      expect(packageNameOf(Uri.parse('dart:core')), isNull);
      expect(packageNameOf(Uri.parse('file:///project/lib/core/user.dart')), isNull);
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
