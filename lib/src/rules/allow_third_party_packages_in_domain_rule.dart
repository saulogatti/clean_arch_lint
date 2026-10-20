import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/error/error.dart';
import 'package:clean_arch_lint/src/lint_utils.dart';

/// Option that lets `domain_only_depends_on_itself` allow third-party
/// packages in `domain`. It never reports anything.
///
/// Analyzer plugins can only be configured through `diagnostics`, so this
/// option is a diagnostic: enable `allow_third_party_packages_in_domain` under
/// `plugins.clean_arch_lint.diagnostics` to allow imports such as
/// `package:equatable/equatable.dart` in `domain`. Flutter SDK packages
/// (`flutterSdkPackages`), `dart:ui`, `dart:io` and the project's other
/// layers stay reported.
///
/// The analyzer runs [registerNodeProcessors] for every enabled rule of a
/// library, with the same [RuleContext], before visiting it; the rule marks
/// that context and [isEnabledFor] reads the mark.
class AllowThirdPartyPackagesInDomainRule extends AnalysisRule {
  /// Creates the rule.
  AllowThirdPartyPackagesInDomainRule()
    : super(
        name: LintNames.allowThirdPartyPackagesInDomain,
        description: 'Lets domain_only_depends_on_itself allow third-party packages in domain.',
      );

  static final Expando<bool> _enabledContexts = Expando('allowThirdPartyPackagesInDomain');

  @override
  DiagnosticCode get diagnosticCode => allowThirdPartyPackagesInDomainCode;

  /// Whether this rule is enabled for the library analyzed with [context].
  ///
  /// Only valid while visiting, after every rule ran [registerNodeProcessors].
  static bool isEnabledFor(RuleContext context) => _enabledContexts[context] ?? false;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    _enabledContexts[context] = true;
  }
}
