import 'package:analysis_server_plugin/registry.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:clean_arch_lint/clean_arch_lint.dart';
import 'package:clean_arch_lint/main.dart';
import 'package:test/test.dart';

void main() {
  test('the top-level plugin is a CleanArchitectureLintPlugin', () {
    expect(plugin, isA<CleanArchitectureLintPlugin>());
    expect(plugin.name, 'Flutter Clean Architecture Lint Plugin');
  });

  test('register adds one lint rule per diagnostic and no warning rule', () async {
    final registry = _RecordingRegistry();
    await CleanArchitectureLintPlugin().register(registry);

    expect(registry.lintRules.map((rule) => rule.name), [
      'no_data_dependencies',
      'no_screens_dependencies',
      'domain_only_depends_on_itself',
      'core_independent',
      'allow_third_party_packages_in_domain',
    ]);
    expect(registry.warningRules, isEmpty);
  });
}

/// Records the rules a plugin registers; the other registry calls are unused.
class _RecordingRegistry implements PluginRegistry {
  final List<AbstractAnalysisRule> lintRules = [];
  final List<AbstractAnalysisRule> warningRules = [];

  @override
  void registerLintRule(AbstractAnalysisRule rule) => lintRules.add(rule);

  @override
  void registerWarningRule(AbstractAnalysisRule rule) => warningRules.add(rule);

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
