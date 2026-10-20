// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/error.dart';

/// Reported when `domain` imports a file outside `lib/**/domain/`.
///
/// Only pure Dart libraries (`dart:async`, `dart:core`, ...) are allowed;
/// `dart:ui`, `dart:io`, Flutter and third-party packages are not.
const LintCodeArchitecture domainOnlyDependsOnItselfCode = LintCodeArchitecture(
  LintNames.domainOnlyDependsOnItself,
  'Domain should only depend on domain and pure Dart libraries.',
  correctionMessage: 'Depend on a domain contract and implement it outside domain.',
  severity: .WARNING,
  uniqueName: 'domain_only_depends_on_itself',
);

/// Reported when `presentation` imports `data`.
const LintCodeArchitecture noDataDependenciesCodeInPresentation = LintCodeArchitecture(
  LintNames.noDataDependencies,
  'Presentation should not depend on data.',
  correctionMessage:
      'Depend on domain use cases or contracts and inject the data implementation '
      'from the composition root.',
  severity: .WARNING,
  uniqueName: 'no_data_dependencies_in_presentation',
);

/// Reported when `screens` imports `data`.
const LintCodeArchitecture noDataDependenciesCodeInScreens = LintCodeArchitecture(
  LintNames.noDataDependencies,
  'Screens should not depend on data.',
  correctionMessage:
      'Depend on domain use cases or contracts and inject the data implementation '
      'from the composition root.',
  severity: .WARNING,
  uniqueName: 'no_data_dependencies_in_screens',
);

/// Reported when `data` or `core` imports `screens` or `presentation`.
const LintCodeArchitecture noScreensDependenciesCode = LintCodeArchitecture(
  LintNames.noScreensDependencies,
  'Data and core should not depend on screens or presentation.',
  correctionMessage: 'Depend on domain or core contracts instead of UI code.',
  severity: .WARNING,
  uniqueName: 'no_screens_dependencies_data_or_presentation',
);

/// Lint code whose [LintCode.name] can be shared across variants.
///
/// [LintCode.name] is what users enable in `plugins.*.diagnostics` and suppress
/// with `// ignore`. [LintCode.uniqueName] must stay unique per variant so the
/// analyzer can tell messages apart.
///
/// Grouping today:
/// - [LintNames.noDataDependencies]: presentation/screens must not import data
/// - [LintNames.noScreensDependencies]: data/core must not import UI layers
/// - [LintNames.domainOnlyDependsOnItself]: domain imports only domain
final class LintCodeArchitecture extends LintCode {
  /// Creates an architecture diagnostic.
  const LintCodeArchitecture(
    super.name,
    super.problemMessage, {
    required super.correctionMessage,
    required super.severity,
    super.uniqueName,
  });
}

/// Diagnostic names enabled under `plugins.clean_arch_lint.diagnostics`.
abstract final class LintNames {
  const LintNames._();

  /// Presentation and screens must not import data.
  static const String noDataDependencies = 'no_data_dependencies';

  /// Domain may import only other domain files.
  static const String domainOnlyDependsOnItself = 'domain_only_depends_on_itself';

  /// Data and core must not import screens or presentation.
  static const String noScreensDependencies = 'no_screens_dependencies';
}
