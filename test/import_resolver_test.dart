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

    test('packageNameOf should extract the package name from a package URI', () {
      expect(packageNameOf(Uri.parse('package:flutter/material.dart')), equals('flutter'));
      expect(packageNameOf(Uri.parse('package:my_app/core/user.dart')), equals('my_app'));
      expect(packageNameOf(Uri.parse('dart:core')), isNull);
      expect(packageNameOf(Uri.parse('file:///project/lib/core/user.dart')), isNull);
    });
  });
}
