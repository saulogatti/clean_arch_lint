import 'package:analyzer/error/error.dart';

//domain so pode ter ele mesmo
const LintCodeArchitecture domainOnlyDependsOnItselfCode = LintCodeArchitecture(
  LintNames.domainOnlyDependsOnItself,
  'Domain should only depend on itself. Domain should not depend on data or presentation.',
  correctionMessage: 'Domain should only depend on itself',
  severity: .WARNING,
  uniqueName: 'domain_only_depends_on_itself',
);
//presentation ou screens nao pode ter dependencias de data
const LintCodeArchitecture noDataDependenciesCodeInPresentation = LintCodeArchitecture(
  LintNames.noDataDependencies,
  'No data dependencies in presentation. Presentation should not depend on data.',
  correctionMessage: 'No data dependencies in presentation',
  severity: .WARNING,
  uniqueName: 'no_data_dependencies_in_presentation',
);
const LintCodeArchitecture noDataDependenciesCodeInScreens = LintCodeArchitecture(
  LintNames.noDataDependencies,
  'No data dependencies in screens. Screens should not depend on data.',
  correctionMessage: 'No data dependencies in screens',
  severity: .WARNING,
  uniqueName: 'no_data_dependencies_in_screens',
);
//presentation ou screens nao pode ter dependencias de data
const LintCodeArchitecture noPresentationDependenciesCode = LintCodeArchitecture(
  LintNames.noScreensDependencies,
  'Presentation should not depend on data. Presentation should only depend on screens or domain.',
  correctionMessage: 'Presentation should not depend on data',
  severity: .WARNING,
  uniqueName: 'no_presentation_dependencies',
);
//presentation ou screens nao pode ter dependencias de data
const LintCodeArchitecture noScreensDependenciesCode = LintCodeArchitecture(
  LintNames.noScreensDependencies,
  'Data should not depend on screens or presentation.',
  correctionMessage: 'Data should not depend on screens or presentation',
  severity: .WARNING,
  uniqueName: 'no_screens_dependencies_data_or_presentation',
);

/// A custom lint code for the architecture rules.
// name pode ser repetido, mas uniqueName nao pode ser repetido. posso usar name para agrupar os lint codes. (ex: data (pode apenas nao pode ter dependencias de presentation) e core tambem pode ter dependencias de data e domain, mas nao de presentation, domain so pode ter ele mesmo, presentation ou screens nao pode ter dependencias de data)
final class LintCodeArchitecture extends LintCode {
  const LintCodeArchitecture(
    super.name,
    super.problemMessage, {
    required super.correctionMessage,
    required super.severity,
    super.uniqueName,
  });
}

abstract final class LintNames {
  const LintNames._();
  static const String noDataDependencies = 'no_data_dependencies';
  static const String domainOnlyDependsOnItself = 'domain_only_depends_on_itself';

  static const String noScreensDependencies = 'no_screens_dependencies';
}
