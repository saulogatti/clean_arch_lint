/// Utilities for resolving and analyzing imports in Dart/Flutter projects.
///
/// Layers are detected from the canonical `package:` URIs the analyzer assigns
/// to every library under `lib/`, so relative and `package:` imports of the
/// same file resolve identically and no file-system path handling is needed.
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

/// Clean Architecture layers, matched by directory name under `lib/` or
/// `lib/src/`.
enum ArchitectureLayer { data, presentation, screens, core, domain }

/// Returns the [ArchitectureLayer] of the library identified by [uri].
///
/// Only `package:` URIs are considered: the layer is the first directory after
/// the package name, or after `src/`. Files outside `lib/` (tests, scripts)
/// have `file:` URIs and return `null`.
///
/// ## Examples
///
/// ```dart
/// layerOf(Uri.parse('package:my_app/data/models/user.dart'));      // data
/// layerOf(Uri.parse('package:my_app/src/domain/entities/u.dart')); // domain
/// layerOf(Uri.parse('package:my_app/main.dart'));                  // null
/// layerOf(Uri.parse('dart:async'));                                // null
/// ```
ArchitectureLayer? layerOf(Uri uri) {
  if (!uri.isScheme('package')) return null;

  final segments = uri.pathSegments;
  final layerIndex = segments.length > 2 && segments[1] == 'src' ? 2 : 1;
  // The layer must be a directory, so at least one segment must follow it.
  if (segments.length <= layerIndex + 1) return null;

  final name = segments[layerIndex];
  for (final layer in ArchitectureLayer.values) {
    if (layer.name == name) return layer;
  }
  return null;
}

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

/// Returns the canonical URI of the library imported by [node].
///
/// Relative imports are resolved by the analyzer, so
/// `import '../data/user.dart';` and
/// `import 'package:my_app/data/user.dart';` return the same URI.
///
/// Returns `null` when the AST is not resolved or the URI is invalid
/// (for example, string interpolation).
Uri? importedUriOf(ImportDirective node) {
  final uri = node.libraryImport?.uri;
  return uri is DirectiveUriWithSource ? uri.source.uri : null;
}

/// Checks if an import is from a Flutter package or related.
///
/// Detects imports from Flutter and UI libraries that should not be
/// used in the core layer. Includes:
///
/// - Flutter packages: `package:flutter/...`
/// - Flutter test packages: `package:flutter_test/...`
/// - dart:ui library (used internally by Flutter)
///
/// Returns `true` if the [uri] is from Flutter/UI, `false` otherwise.
///
/// ## Examples
///
/// ```dart
/// isFlutterImport('package:flutter/material.dart');      // true
/// isFlutterImport('package:flutter/widgets.dart');       // true
/// isFlutterImport('package:flutter_test/flutter_test.dart'); // true
/// isFlutterImport('dart:ui');                            // true
/// isFlutterImport('dart:core');                          // false
/// isFlutterImport('package:my_app/core/user.dart');     // false
/// ```
bool isFlutterImport(String uri) {
  return uri.startsWith('package:flutter/') ||
      uri.startsWith('package:flutter_test/') ||
      uri == 'dart:ui';
}
