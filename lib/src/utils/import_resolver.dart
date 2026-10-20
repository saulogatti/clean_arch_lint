/// Utilities for resolving and analyzing imports in Dart/Flutter projects.
///
/// Layers are detected from the canonical `package:` URIs the analyzer assigns
/// to every library under `lib/`, so relative and `package:` imports of the
/// same file resolve identically and no file-system path handling is needed.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

/// Clean Architecture layers, matched by directory name under `lib/`,
/// `lib/src/`, or `features/<feature>/` inside either of them, or by the
/// `_{layer}` suffix of a package name (see [packageLayerOf]).
enum ArchitectureLayer { data, presentation, screens, core, domain }

/// Returns the [ArchitectureLayer] of the library identified by [uri].
///
/// Only `package:` URIs are considered: the layer is the first directory after
/// the package name, or after `src/`. In a feature-first layout the layer is
/// the directory after [featuresDirectory] and the feature name. Files outside
/// `lib/` (tests, scripts) have `file:` URIs and return `null`.
///
/// When no directory names a layer, the layer comes from the package name
/// ([packageLayerOf]), so every library of a layer package such as
/// `my_app_data` belongs to that layer.
///
/// The feature name plays no part in the checks: imports between features
/// follow the same layer rules as any other import.
///
/// ## Examples
///
/// ```dart
/// layerOf(Uri.parse('package:my_app/data/models/user.dart'));      // data
/// layerOf(Uri.parse('package:my_app/src/domain/entities/u.dart')); // domain
/// layerOf(Uri.parse('package:my_app/features/cart/data/cart.dart')); // data
/// layerOf(Uri.parse('package:my_app_data/my_app_data.dart'));      // data
/// layerOf(Uri.parse('package:my_app/main.dart'));                  // null
/// layerOf(Uri.parse('dart:async'));                                // null
/// ```
ArchitectureLayer? layerOf(Uri uri) {
  if (!uri.isScheme('package') || uri.pathSegments.isEmpty) return null;
  return _directoryLayerOf(uri.pathSegments) ?? packageLayerOf(uri.pathSegments.first);
}

ArchitectureLayer? _directoryLayerOf(List<String> segments) {
  var layerIndex = segments.length > 2 && segments[1] == 'src' ? 2 : 1;
  // Skip `features/<feature>/` to reach the layer.
  if (segments.length > layerIndex + 2 && segments[layerIndex] == featuresDirectory) {
    layerIndex += 2;
  }
  // The layer must be a directory, so at least one segment must follow it.
  if (segments.length <= layerIndex + 1) return null;

  final name = segments[layerIndex];
  for (final layer in ArchitectureLayer.values) {
    if (layer.name == name) return layer;
  }
  return null;
}

/// Directory that groups features in a feature-first layout
/// (`lib/features/<feature>/{layer}/...`).
const String featuresDirectory = 'features';

/// Returns the package name of a `package:` [uri], or `null` for any other
/// scheme.
///
/// ## Examples
///
/// ```dart
/// packageNameOf(Uri.parse('package:flutter/material.dart')); // 'flutter'
/// packageNameOf(Uri.parse('dart:core'));                     // null
/// ```
String? packageNameOf(Uri uri) {
  if (!uri.isScheme('package') || uri.pathSegments.isEmpty) return null;
  return uri.pathSegments.first;
}

/// Returns the layer named by the `_{layer}` suffix of [packageName], or
/// `null` when it has none.
///
/// Supports monorepos with one package per layer (`my_app_domain`,
/// `my_app_data`, `my_app_presentation`, ...). The suffix must follow a
/// non-empty prefix, so a package named just `data` has no layer.
///
/// ## Examples
///
/// ```dart
/// packageLayerOf('my_app_data');         // data
/// packageLayerOf('my_app_presentation'); // presentation
/// packageLayerOf('my_app');              // null
/// packageLayerOf('data');                // null
/// ```
ArchitectureLayer? packageLayerOf(String packageName) {
  for (final layer in ArchitectureLayer.values) {
    final suffix = '_${layer.name}';
    if (packageName.length > suffix.length && packageName.endsWith(suffix)) return layer;
  }
  return null;
}

/// Returns the project that [packageName] belongs to: the name without its
/// layer suffix ([packageLayerOf]), or the name itself when it has none.
///
/// ## Examples
///
/// ```dart
/// projectNameOf('my_app_data'); // 'my_app'
/// projectNameOf('my_app');      // 'my_app'
/// ```
String projectNameOf(String packageName) {
  final layer = packageLayerOf(packageName);
  if (layer == null) return packageName;
  return packageName.substring(0, packageName.length - layer.name.length - 1);
}

/// Whether the libraries at [currentUri] and [importedUri] belong to the same
/// project, so the layer of [importedUri] counts.
///
/// That is the same package, or packages with the same [projectNameOf]: in a
/// monorepo, `my_app`, `my_app_domain` and `my_app_data` are one project.
/// Third-party packages that merely end in a layer name, such as
/// `firebase_core`, belong to another project.
///
/// ## Examples
///
/// ```dart
/// final current = Uri.parse('package:my_app_presentation/page.dart');
/// isSameProject(current, Uri.parse('package:my_app_data/user.dart'));    // true
/// isSameProject(current, Uri.parse('package:my_app/data/user.dart'));    // true
/// isSameProject(current, Uri.parse('package:firebase_core/core.dart'));  // false
/// isSameProject(current, Uri.parse('dart:io'));                          // false
/// ```
bool isSameProject(Uri currentUri, Uri importedUri) {
  final currentPackage = packageNameOf(currentUri);
  final importedPackage = packageNameOf(importedUri);
  return currentPackage != null &&
      importedPackage != null &&
      projectNameOf(currentPackage) == projectNameOf(importedPackage);
}

/// Packages shipped with the Flutter SDK.
///
/// They are never treated as third-party packages, so
/// `allow_third_party_packages_in_domain` does not allow Flutter in `domain`.
const Set<String> flutterSdkPackages = {
  'flutter',
  'flutter_driver',
  'flutter_localizations',
  'flutter_test',
  'flutter_web_plugins',
  'integration_test',
  'sky_engine',
};

/// Whether [importedUri] is a library of a third-party package, seen from the
/// library at [currentUri].
///
/// A third-party package is any `package:` outside the current project
/// ([isSameProject]) and the [flutterSdkPackages]. `dart:` libraries are never
/// third-party packages.
///
/// ## Examples
///
/// ```dart
/// final current = Uri.parse('package:my_app/domain/user.dart');
/// isThirdPartyPackage(current, Uri.parse('package:equatable/equatable.dart')); // true
/// isThirdPartyPackage(current, Uri.parse('package:flutter/widgets.dart'));     // false
/// isThirdPartyPackage(current, Uri.parse('package:my_app/data/user.dart'));    // false
/// isThirdPartyPackage(current, Uri.parse('package:my_app_data/user.dart'));    // false
/// isThirdPartyPackage(current, Uri.parse('dart:io'));                          // false
/// ```
bool isThirdPartyPackage(Uri currentUri, Uri importedUri) {
  final importedPackage = packageNameOf(importedUri);
  return importedPackage != null &&
      !isSameProject(currentUri, importedUri) &&
      !flutterSdkPackages.contains(importedPackage);
}

/// Dart SDK libraries that are plain language support, with no UI, I/O or
/// platform access.
///
/// These are allowed in every layer, including `domain`. Any other `dart:`
/// library (`dart:ui`, `dart:io`, `dart:html`, `dart:ffi`, ...) is treated as
/// an import from outside the project's layers, so `domain` reports it.
const Set<String> pureDartLibraries = {
  'async',
  'collection',
  'convert',
  'core',
  'math',
  'typed_data',
};

/// Whether [uri] is one of the [pureDartLibraries].
///
/// ## Examples
///
/// ```dart
/// isPureDartLibrary(Uri.parse('dart:async')); // true
/// isPureDartLibrary(Uri.parse('dart:ui'));    // false
/// isPureDartLibrary(Uri.parse('dart:io'));    // false
/// ```
bool isPureDartLibrary(Uri uri) => uri.isScheme('dart') && pureDartLibraries.contains(uri.path);

/// Returns the canonical URI of the library imported by [node].
///
/// Relative imports are resolved by the analyzer, so
/// `import '../data/user.dart';` and
/// `import 'package:my_app/data/user.dart';` return the same URI.
///
/// Returns `null` when the AST is not resolved or the URI is invalid
/// (for example, string interpolation).
Uri? importedUriOf(ImportDirective node) => _sourceUriOf(node.libraryImport?.uri);

/// Returns the canonical URI of the library exported by [node].
///
/// Resolved like [importedUriOf]: relative and `package:` exports of the same
/// file return the same URI, and `null` means the AST is not resolved or the
/// URI is invalid.
Uri? exportedUriOf(ExportDirective node) => _sourceUriOf(node.libraryExport?.uri);

Uri? _sourceUriOf(DirectiveUri? uri) => uri is DirectiveUriWithSource ? uri.source.uri : null;
