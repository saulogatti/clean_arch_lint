// ignore_for_file: public_member_api_docs, sort_constructors_first
/// Represents a resolved import with information about its location.
///
/// Contains both the normalized file path and the original URI,
/// allowing tracking of the import's origin during static analysis.
///
/// ## Example
///
/// ```dart
/// final resolved = ResolvedImport(
///   resolvedPath: '/project/lib/core/entities/user.dart',
///   originalUri: 'package:my_app/core/entities/user.dart',
/// );
/// ```
class ResolvedImport {
  /// Normalized and absolute path of the imported file.
  ///
  /// Uses `/` as directory separator regardless of operating system.
  final String resolvedPath;

  /// Original URI from the import directive, without modifications.
  ///
  /// Can be a package import (`package:...`), relative import (`../...`),
  /// or dart import (`dart:...`).
  final String originalUri;

  /// Creates an instance of [ResolvedImport].
  const ResolvedImport({required this.resolvedPath, required this.originalUri});

  @override
  String toString() => 'ResolvedImport(resolvedPath: $resolvedPath, originalUri: $originalUri)';
}
