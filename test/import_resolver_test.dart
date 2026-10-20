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

    test('layerOf should detect the layer from features/<feature>/{layer}/', () {
      expect(
        layerOf(Uri.parse('package:my_app/features/cart/data/models/cart.dart')),
        ArchitectureLayer.data,
      );
      expect(
        layerOf(Uri.parse('package:my_app/src/features/cart/presentation/page.dart')),
        ArchitectureLayer.presentation,
      );
      // A feature named like a layer is skipped too.
      expect(
        layerOf(Uri.parse('package:my_app/features/data/domain/user.dart')),
        ArchitectureLayer.domain,
      );
    });

    test('layerOf should return null in a feature outside a layer directory', () {
      expect(layerOf(Uri.parse('package:my_app/features/cart/cart.dart')), isNull);
      expect(layerOf(Uri.parse('package:my_app/features/cart/data.dart')), isNull);
      expect(layerOf(Uri.parse('package:my_app/features/cart/widgets/data/a.dart')), isNull);
      expect(layerOf(Uri.parse('package:my_app/features/cart.dart')), isNull);
    });

    test('layerOf should fall back to the layer suffix of the package name', () {
      expect(layerOf(Uri.parse('package:my_app_data/my_app_data.dart')), ArchitectureLayer.data);
      expect(
        layerOf(Uri.parse('package:my_app_presentation/src/widgets/button.dart')),
        ArchitectureLayer.presentation,
      );
      // A layer directory wins over the package name.
      expect(layerOf(Uri.parse('package:my_app_data/domain/user.dart')), ArchitectureLayer.domain);
    });

    test('packageLayerOf should read the _{layer} suffix of a package name', () {
      expect(packageLayerOf('my_app_core'), ArchitectureLayer.core);
      expect(packageLayerOf('my_app_data'), ArchitectureLayer.data);
      expect(packageLayerOf('my_app_domain'), ArchitectureLayer.domain);
      expect(packageLayerOf('my_app_presentation'), ArchitectureLayer.presentation);
      expect(packageLayerOf('my_app_screens'), ArchitectureLayer.screens);
      expect(packageLayerOf('my_app'), isNull);
      expect(packageLayerOf('data'), isNull);
      expect(packageLayerOf('_data'), isNull);
      expect(packageLayerOf('metadata'), isNull);
    });

    test('projectNameOf should strip the layer suffix', () {
      expect(projectNameOf('my_app_data'), 'my_app');
      expect(projectNameOf('my_app_presentation'), 'my_app');
      expect(projectNameOf('my_app'), 'my_app');
      expect(projectNameOf('data'), 'data');
    });

    test('isSameProject should accept the same package and sibling layer packages', () {
      final current = Uri.parse('package:my_app_presentation/page.dart');
      expect(isSameProject(current, Uri.parse('package:my_app_presentation/a.dart')), isTrue);
      expect(isSameProject(current, Uri.parse('package:my_app_data/user.dart')), isTrue);
      expect(isSameProject(current, Uri.parse('package:my_app/data/user.dart')), isTrue);
      expect(isSameProject(current, Uri.parse('package:other_data/user.dart')), isFalse);
      expect(isSameProject(current, Uri.parse('package:firebase_core/core.dart')), isFalse);
      expect(isSameProject(current, Uri.parse('package:my_app_widgets/a.dart')), isFalse);
      expect(isSameProject(current, Uri.parse('dart:io')), isFalse);
      expect(isSameProject(Uri.parse('file:///p/test/a_test.dart'), current), isFalse);
    });

    test('layerOf should return null outside a layer directory', () {
      expect(layerOf(Uri.parse('package:my_app/main.dart')), isNull);
      expect(layerOf(Uri.parse('package:my_app/data.dart')), isNull);
      expect(layerOf(Uri.parse('package:my_app/src/data.dart')), isNull);
      expect(layerOf(Uri.parse('package:my_app/widgets/data/button.dart')), isNull);
      expect(layerOf(Uri.parse('dart:async')), isNull);
      expect(layerOf(Uri.parse('file:///project/test/data/user_test.dart')), isNull);
    });

    test('isThirdPartyPackage should accept only other non-Flutter packages', () {
      final current = Uri.parse('package:my_app/domain/user.dart');
      expect(isThirdPartyPackage(current, Uri.parse('package:equatable/equatable.dart')), isTrue);
      expect(isThirdPartyPackage(current, Uri.parse('package:other/data/user.dart')), isTrue);
      expect(isThirdPartyPackage(current, Uri.parse('package:my_app/data/user.dart')), isFalse);
      expect(isThirdPartyPackage(current, Uri.parse('package:my_app_data/user.dart')), isFalse);
      expect(isThirdPartyPackage(current, Uri.parse('package:firebase_core/core.dart')), isTrue);
      expect(isThirdPartyPackage(current, Uri.parse('package:flutter/widgets.dart')), isFalse);
      expect(
        isThirdPartyPackage(current, Uri.parse('package:flutter_test/flutter_test.dart')),
        isFalse,
      );
      expect(isThirdPartyPackage(current, Uri.parse('dart:io')), isFalse);
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
