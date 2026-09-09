// ignore_for_file: deprecated_member_use

import 'package:analyzer/error/error.dart';

/// Reported when `domain` imports a file outside `lib/**/domain/`.
///
/// Dart SDK imports (`dart:async`, …) are not resolved as project files, so they
/// are allowed. Flutter and third-party packages are not.
const LintCodeArchitecture domainOnlyDependsOnItselfCode = LintCodeArchitecture(
  LintNames.domainOnlyDependsOnItself,
  'Domain should only depend on itself. Domain should not depend on data or presentation.',
  correctionMessage: 'Domain should only depend on itself',
  severity: .WARNING,
  uniqueName: 'domain_only_depends_on_itself',
);

/// Reported when `presentation` (or `data`/`core` targeting presentation) breaks
/// the inward-only dependency rule.
const LintCodeArchitecture noDataDependenciesCodeInPresentation = LintCodeArchitecture(
  LintNames.noDataDependencies,
  'No data dependencies in presentation. Presentation should not depend on data.',
  correctionMessage: 'No data dependencies in presentation',
  severity: .WARNING,
  uniqueName: 'no_data_dependencies_in_presentation',
);

/// Reported when `screens` (or `data`/`core` targeting screens) breaks the
/// inward-only dependency rule.
const LintCodeArchitecture noDataDependenciesCodeInScreens = LintCodeArchitecture(
  LintNames.noDataDependencies,
  'No data dependencies in screens. Screens should not depend on data.',
  correctionMessage: 'No data dependencies in screens',
  severity: .WARNING,
  uniqueName: 'no_data_dependencies_in_screens',
);

/// Grouped under [LintNames.noScreensDependencies]: presentation must not depend
/// on data; it may depend on screens or domain.
const LintCodeArchitecture noPresentationDependenciesCode = LintCodeArchitecture(
  LintNames.noScreensDependencies,
  'Presentation should not depend on data. Presentation should only depend on screens or domain.',
  correctionMessage: 'Presentation should not depend on data',
  severity: .WARNING,
  uniqueName: 'no_presentation_dependencies',
);

/// Grouped under [LintNames.noScreensDependencies]: data must not depend on
/// screens or presentation.
const LintCodeArchitecture noScreensDependenciesCode = LintCodeArchitecture(
  LintNames.noScreensDependencies,
  'Data should not depend on screens or presentation.',
  correctionMessage: 'Data should not depend on screens or presentation',
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
