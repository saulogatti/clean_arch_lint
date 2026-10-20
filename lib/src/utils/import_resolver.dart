/// Utilities for resolving and analyzing imports in Dart/Flutter projects.
///
/// Layers are detected from the canonical `package:` URIs the analyzer assigns
/// to every library under `lib/`, so relative and `package:` imports of the
/// same file resolve identically and no file-system path handling is needed.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

/// Clean Architecture layers, matched by directory name under `lib/`,
/// `lib/src/`, or `features/<feature>/` inside either of them.
enum ArchitectureLayer { data, presentation, screens, core, domain }

/// Returns the [ArchitectureLayer] of the library identified by [uri].
///
/// Only `package:` URIs are considered: the layer is the first directory after
/// the package name, or after `src/`. In a feature-first layout the layer is
/// the directory after [featuresDirectory] and the feature name. Files outside
/// `lib/` (tests, scripts) have `file:` URIs and return `null`.
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
/// layerOf(Uri.parse('package:my_app/main.dart'));                  // null
/// layerOf(Uri.parse('dart:async'));                                // null
/// ```
ArchitectureLayer? layerOf(Uri uri) {
  if (!uri.isScheme('package')) return null;

  final segments = uri.pathSegments;
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
/// A third-party package is any `package:` other than the current one and the
/// [flutterSdkPackages]. `dart:` libraries are never third-party packages.
///
/// ## Examples
///
/// ```dart
/// final current = Uri.parse('package:my_app/domain/user.dart');
/// isThirdPartyPackage(current, Uri.parse('package:equatable/equatable.dart')); // true
/// isThirdPartyPackage(current, Uri.parse('package:flutter/widgets.dart'));     // false
/// isThirdPartyPackage(current, Uri.parse('package:my_app/data/user.dart'));    // false
/// isThirdPartyPackage(current, Uri.parse('dart:io'));                          // false
/// ```
bool isThirdPartyPackage(Uri currentUri, Uri importedUri) {
  final importedPackage = packageNameOf(importedUri);
  return importedPackage != null &&
      importedPackage != packageNameOf(currentUri) &&
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
