import 'dart:io'; // ❌ domain_only_depends_on_itself

/// ❌ BAD EXAMPLE: Domain importing an SDK library with I/O access.
///
/// Violation of `domain_only_depends_on_itself`. Only pure Dart libraries
/// (`dart:core`, `dart:async`, `dart:collection`, `dart:convert`, `dart:math`,
/// `dart:typed_data`) are allowed in domain.
bool hasLocalCache(String path) => File(path).existsSync();
